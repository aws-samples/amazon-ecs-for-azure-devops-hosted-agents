## Amazon ECS for Azure DevOps Hosted Agents

### Introduction

AWS offers various services to build and deploy applications, including [AWS CodeBuild](https://aws.amazon.com/codebuild), [AWS CodePipeline](https://aws.amazon.com/codepipeline), and [Amazon CodeCatalyst](https://aws.amazon.com/codecatalyst). If you’re using Microsoft’s Azure DevOps, you can also use Azure Pipelines to build and release applications on AWS. Azure Pipelines works with both the cloud-based Azure DevOps Services and the on-premises Azure DevOps Server.

AWS customers using Azure DevOps (referred to as ADO from here onward) for their CI/CD pipelines can use self-hosted agents to build, test, and deploy AWS applications. Self-hosted agents provide more control and customization. With self-hosted Azure Pipelines static agents on Amazon EC2 instances, there is no built-in dynamic scaling capability for agent pools. Providing too few agents can lead to long build times due to insufficient capacity. On the other hand, provisioning too many agents will result in paying for excess unused capacity when they are idle.

With the solution part of this repository, we will demonstrate how to use Amazon ECS with AWS Fargate to orchestrate container-based, dynamic, on-demand, self-hosted agents, which will provide a simple, secure, and automated solution for your ADO agent pools. 
**Note: Because the agents run as containers themselves, this solution is not suitable for pipeline jobs that include building container images.**

### Solution overview
We will break up this solution into two parts. First, we will show you how you can use AWS developer tools to build and push a customized agent image to [Amazon Elastic Container Registry (Amazon ECR)](https://aws.amazon.com/ecr/). Then we’ll show you how to provision self-hosted hosted agents with the use of [ADO agent pool Approvals and Checks](https://learn.microsoft.com/en-us/azure/devops/pipelines/process/approvals?view=azure-devops&tabs=check-pass).

Figure 1 includes a Terraform stack that is designed to simplify the deployment process. When you deploy this Terraform stack, it creates an AWS CodeCommit repository, AWS CodePipeline, Amazon ECR repository, Amazon ECS cluster with a [task definition](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definitions.html), [AWS Lambda](https://aws.amazon.com/lambda/) functions and [Amazon API Gateway](https://aws.amazon.com/api-gateway/) (item 1).

![Amazon ECS as ADO hosted agents - Process Overview](https://d2908q01vomqb2.cloudfront.net/8effee409c625e1a2d8f5033631840e6ce1dcb64/2024/02/09/Picture-1-2.png)
_Figure 1: Amazon ECS as ADO hosted agents - Process Overview_

The task definition is configured with CPU and memory at 0.25 vCPU and 512 MiB, respectively, along with environment variables for ADO-related parameters. While the provided Terraform stack and Dockerfile help deploy the stack with a custom image to be built and pushed to Amazon ECR, you could alternatively choose to make use of your own existing tools and container images. The AWS CodeCommit repository contains a Dockerfile with instructions on how to build the ADO agent Docker image, along with any application-specific build tooling. The AWS CodePipeline is configured to source from AWS CodeCommit, and it has an AWS CodeBuild stage that builds and pushes a container image, including the ADO agent software, to an Amazon ECR repository.

When an Azure Pipelines job is triggered in ADO (item 2), it invokes the Amazon API Gateway endpoint, which is configured in the ADO agent pool’s settings - Approvals and Checks option.

Amazon API Gateway invokes the integrated Lambda function (`create_ecs_task`), which, in turn, triggers the Amazon ECS task (item 3). A response is sent back to ADO, and the pipeline waits for the agent to be provisioned. The Amazon ECS cluster uses the container image retrieved from the Amazon ECR repository to run an Amazon ECS task.
Simultaneously, the `create_ecs_task` function invokes the get_ecs_task Lambda function, passing details from the initial API call, including job specifics, in the Lambda event. Then the `get_ecs_task` function begins polling the status of the Amazon ECS task. When it detects that the task status is in the `RUNNING` state, it sends a callback to ADO agent pool's Approvals and Checks process to proceed with its pipeline execution. The Lambda functions, therefore, act as intermediaries between ADO and the Amazon ECS task by creating an agent and updating its availability in the ADO agent pool.

When the Amazon ECS task container instance transitions to the `RUNNING` state, it gets registered in the ADO agent pool. Azure Pipelines can then use the Amazon ECS task to run the pipeline. It’s important to note that the lifespan of the Amazon ECS task is directly tied to the duration of the corresponding pipeline job within ADO.

The authentication procedure for enrolling the Amazon ECS container instance into the ADO agent pool is accomplished by using a personal access token (PAT). There is no need to configure AWS credentials because the access to AWS resources is handled via the Amazon ECS task and task execution [Identity and Access Management (IAM)](https://aws.amazon.com/iam) roles, thus eliminating the need to configure AWS credentials in ADO.

### Prerequisites

Here are the prerequisites to use this solution for your Azure Pipelines agents:

- An AWS account that you have permissions to deploy this into, with credentials for the account [configured locally for Terraform deployment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs#authentication-and-configuration).
- An [Amazon Virtual Private Cloud (VPC)](https://aws.amazon.com/vpc) in that account with a public subnet and a security group with an egress rule that allows connections to 0.0.0.0/0 (any IPv4 address).
- Command line tools: [git](https://git-scm.com/downloads), [Terraform](https://developer.hashicorp.com/terraform/install), [AWS Command Line Interface (AWS CLI)](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html), and [git-remote-codecommit](https://docs.aws.amazon.com/codecommit/latest/userguide/setting-up-git-remote-codecommit.html#setting-up-git-remote-codecommit-prereq).
- An [Azure Pipelines agent pool provisioned](https://learn.microsoft.com/en-us/azure/devops/pipelines/agents/pools-queues?view=azure-devops&tabs=yaml%2Cbrowser). The new agents will be added to and removed from this pool.
- An ADO PAT that has the necessary permissions to install and register ADO agents. It will be stored in an [AWS Secrets Manager](https://aws.amazon.com/secrets-manager/) secret created by the Terraform stack. You can refer to the documentation to learn [how to create a personal access token](https://learn.microsoft.com/en-us/azure/devops/organizations/accounts/use-personal-access-tokens-to-authenticate).

### Walk-through

You’ll be performing the following tasks to set up the solution:

- Clone the GitHub repository and deploy the required solution components into your AWS account.
- Push the ADO agent folder to the AWS CodeCommit repository that is created as part of the Terraform stack.
- Configure the ADO agent pool’s Approvals and Checks.
- Configure the sample repository in ADO to use the Amazon ECS-based hosted agent, which runs the command `aws sts get-caller-identity`, by assuming the Amazon ECS task role, to confirm successful completion. Note that this is only a simple example to establish that the hosted agent has access to AWS.

#### AWS deployment and configurations

The first procedure is to create the AWS components needed to deploy the Azure Pipelines agents.

- Clone this repository and navigate to the folder `amazon-ecs-for-azure-devops-hosted-agents`.
- Update the placeholders in the `terraform.tfvars` file with values related to your AWS account and ADO environment.
- Run the command `terraform init` to initialize Terraform in your environment.
- Run the command `terraform plan`, and review the output to ensure it ran successfully.
- Finally, run `terraform apply` and validate that it deployed resources without any errors. The output will be similar to Figure 3.

![Screenshot of Terraform console output showing number of resources expected to be created in black background with white text](https://d2908q01vomqb2.cloudfront.net/8effee409c625e1a2d8f5033631840e6ce1dcb64/2024/02/08/image3-2.png)
_Figure 3: Console showing expected Terraform outputs_

Make note of output values for the following:

The AWS CodeCommit repository URI, which will be used to push the required code to create source code for the pipeline which builds ADO agent image. It will be available as the Terraform output `clone_url_http_grc`.
The Amazon API Gateway endpoint, which will be used in the ADO configuration. It will be available as the Terraform output `ecs_ado_api_invoke_url`.

With the Terraform stack deployed, you will need to prepare a few more resources to ensure the solution functions as expected. At this stage, there will be an AWS CodeCommit repository created as listed in the output `clone_url_http_grc`.

See [TERRAFORM_INFO](TERRAFORM_INFO.md) for more information on resources, variables and output.

1. Navigate locally to the `ado_agent_repo` subdirectory of `amazon-ecs-for-azure-devops-hosted-agents`

2. Run the following commands to push to your AWS CodeCommit repository. Replace `<region>` with the region you are currently using:

git init --initial-branch=main
git remote add cc codecommit::<region>://ado-ecs-repo
git add .
git commit -m “Add ado agent docker files”
git push --set-upstream cc main

This will automatically trigger the AWS CodePipeline `ado-ecs-runner-pipeline`, which will use AWS CodeBuild to build and push the container image for the Azure Pipelines agent. You can navigate to AWS CodePipeline and AWS CodeBuild in the AWS Management Console to ensure this process completes.

3. Once complete, validate that the image is published by navigating to Amazon ECR in the AWS Management Console and checking for the `ado-ecs-ecr` repository, which should contain an image with the tag `ado-ecs`. This is the container image that will be used by the Amazon ECS task later in the process.

4. Refer to the [updating secret value in AWS Secret Manager guide](https://docs.aws.amazon.com/secretsmanager/latest/userguide/manage_update-secret-value.html), and update the ADO PAT value as plaintext (generated as part of the prerequisite steps) in the AWS Secrets Manager console. Update the secret resource created during terraform deployment: `ecs-ado-pat-secret`.

#### Azure DevOps configurations

You are now ready to configure ADO to use Amazon ECS by following these steps.

1. In ADO, configure a Service Connection of type Generic with the Server URL value set with API Gateway endpoint listed as `ecs_ado_api_invoke_url` from the Terraform output. Ensure that Grant access permissions to all pipelines is checked (Figure 4).

![Screenshot of ADO console showing options to configure Service Connection](https://d2908q01vomqb2.cloudfront.net/8effee409c625e1a2d8f5033631840e6ce1dcb64/2024/02/08/image4.png)
_Figure 4: Adding ADO Service Connection_

2. Configure the agent pool’s Approvals and Checks by navigating to ADO project settings, and choose Agent Pools. Select the agent pool that the dynamic agents need to be assigned to. Choose Approvals and checks and then choose the “+” sign to add “Invoke REST API” based checks (Figure 5).

![Screenshot showing configuration for Add REST API check under Agent pool's Approval and Checks submenu](https://d2908q01vomqb2.cloudfront.net/8effee409c625e1a2d8f5033631840e6ce1dcb64/2024/02/08/image5.png)
_Figure 5: Add REST API check_

3. Select the service connection created in the previous step. The Headers field will be populated automatically, as shown in Figure 6.

![Screenshot showing detailed Configuration for Approvals and Checks using Invoke REST API for the agent pool](https://d2908q01vomqb2.cloudfront.net/8effee409c625e1a2d8f5033631840e6ce1dcb64/2024/02/08/Image6.png)
_Figure 6: Configuring Approvals and Checks using Invoke REST API for the agent pool_

4. Next, you will create an empty repository to test the agent running in Amazon ECS as a short- lived task. Create the repository in your project using the provided instructions.
5. Create a new file in the repository with the name `ecs-ado-pipeline.yaml`. This will open an inline editor in the console.

Add the following content and commit changes into the main branch. Replace `[agent-pool-name]` with the agent pool you previously configured.

```yaml
pool:
  name: [agent-pool-name] #Replace with your configured agent pool name

trigger:
  batch: true
  branches:
    include:
      - "*"

steps:
  - checkout: self
    clean: true
    fetchDepth: 1
    path: s
  - script: |
      aws sts get-caller-identity
    workingDirectory: $(System.DefaultWorkingDirectory)
    displayName: Test aws cli
```

6. Create a new pipeline for testing by navigating to Pipelines, and choose New Pipeline.
7. Select “Azure Repos Git” as the source for the pipeline. Choose the repository you just created.
8. Choose “Existing Azure Pipelines YAML file”.
9. Select `ecs-ado-pipeline.yaml` from the drop-down, and choose Continue (Figure 7).

![Screenshot showing how to Configure pipeline with existing pipeline YAML file](https://d2908q01vomqb2.cloudfront.net/8effee409c625e1a2d8f5033631840e6ce1dcb64/2024/02/08/Image7.png)
_Figure 7: Configure pipeline with existing pipeline YAML file_

#### Testing

1. Once you have created the Azure Pipeline, choose Run. This will display a prompt for permissions on the agent pool (Figure 8). Choose Permit to proceed.

![Screenshot indicating button to click in order to permit pipeline to use agent pool in Azure DevOps](https://d2908q01vomqb2.cloudfront.net/8effee409c625e1a2d8f5033631840e6ce1dcb64/2024/02/08/Image8.png)

_Figure 8: Pipeline indicating one-time permission to use agent pool_

2. This will trigger Approvals and Checks, which will, in turn, invoke Amazon ECS to provision an ADO agent. At this stage, ADO makes an API call with the payload and waits for a callback from the `create-ecs-task` Lambda function (Figure 9).

![Screenshot indicating pipeline job waiting for checks to complete](https://d2908q01vomqb2.cloudfront.net/8effee409c625e1a2d8f5033631840e6ce1dcb64/2024/02/08/Image9.png)
_Figure 9: Pipeline job waiting for checks to complete_

3. Navigate to the [Amazon ECS console](https://console.aws.amazon.com/ecs/v2/clusters), and choose your Amazon ECS cluster.
4. Choose the Tasks tab to access active tasks.
5. There should be single task at this stage in this cluster, with a Last status of `Running` as shown in Figure 10.

![Screenshot indicating Amazon ECS tasks showing a successfully running task](https://d2908q01vomqb2.cloudfront.net/8effee409c625e1a2d8f5033631840e6ce1dcb64/2024/02/08/Image10.png)
_Figure 10: Amazon ECS tasks showing a successfully running task_

6. In the ADO agent pool, once the Approvals and Checks has passed, the job is queued to run (Figure 11).

![Figure 11: Screenshot indicating successful completion of `Approvals and Checks`](https://d2908q01vomqb2.cloudfront.net/8effee409c625e1a2d8f5033631840e6ce1dcb64/2024/02/08/Image11.png)
_Figure 11: Screenshot indicating successful completion of `Approvals and Checks`_

7. The job will process an agent running as an Amazon ECS task. Figure 12 displays example output.

![Figure 12: Screenshot showing successful pipeline job execution](https://d2908q01vomqb2.cloudfront.net/8effee409c625e1a2d8f5033631840e6ce1dcb64/2024/02/08/Image12.png)
_Figure 12: Screenshot showing successful pipeline job execution_

8. If you choose the ‘Test aws cli’ step, it will show (Figure 13) that the task running in Amazon ECS was able to successfully assume the task IAM role and run the example command to fetch caller identity information.

![Figure 13: Screenshot indicating agent task running with configured IAM Role](https://d2908q01vomqb2.cloudfront.net/8effee409c625e1a2d8f5033631840e6ce1dcb64/2024/02/08/Image13.png)
_Figure 13: Screenshot indicating agent task running with configured IAM Role_


### Clean-up

Deploying this solution will provision resources and incur costs. Once you have completed testing and you no longer need the setup, remove provisioned resources to avoid unintended costs:

First, remove the ADO agent image in the `ado-ecs-ecr` Amazon ECR repository.
Navigate locally to the folder containing the solution that you cloned and run the following command to de-provision the infrastructure:
`terraform destroy —auto-approve`
In ADO, manually remove the source repository, pipeline, agent pool, and service connection that you created.

## Security

See [CONTRIBUTING](CONTRIBUTING.md#security-issue-notifications) for more information.

## License

This library is licensed under the MIT-0 License. See the LICENSE file.

