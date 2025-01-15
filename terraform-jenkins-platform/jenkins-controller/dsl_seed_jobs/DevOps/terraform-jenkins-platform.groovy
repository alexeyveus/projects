multibranchPipelineJob("terraform-jenkins-platform") {
  branchSources {
    branchSource {
      source {
        bitbucket {
          credentialsId("BBCloudDevOpsProjectAccessToken")
          repoOwner("retailinmotion")
          repository("terraform-jenkins-platform")                       
          traits {
            bitbucketBranchDiscovery {
              strategyId(1)
              // Determines which branches are discovered.
              // Exclude branches that are also filed as PRs - 1
              // If you are discovering origin pull requests, it may not make sense to discover the same changes both as a pull request and as a branch.
              // Only branches that are also filed as PRs - 2
              // Discovers branches that have PR's associated with them. This may make sense if you have a notification sent to the team at the end of a triggered build or limited Jenkins resources.
              // All branches - 3
              // Ignores whether the branch is also filed as a pull request and instead discovers all branches on the origin repository.            
            }
            bitbucketPullRequestDiscovery {
              strategyId(2)
              // Determines how pull requests are discovered.
              // Merging the pull request with the current target branch revision -1 
              // Discover each pull request once with the discovered revision corresponding to the result of merging with the current revision of the target branch
              // The current pull request revision - 2
              // Discover each pull request once with the discovered revision corresponding to the pull request head revision without merging
              // Both the current pull request revision and the pull request merged with the current target branch revision - 3
              // Discover each pull request twice. The first discovered revision corresponds to the result of merging with the current revision of the target branch in each scan. The second parallel discovered revision corresponds to the pull request head revision without merging
            }
            headWildcardFilter {
              includes('*')
              excludes("feature")
            }
            bitbucketSshCheckout {
              credentialsId("jenkins.svn-bitbucket-cloud")
            }
            cloneOption {
              extension {
                // Perform shallow clone, so that git will not download the history of the project, saving time and disk space when you just want to access the latest version of a repository.
                shallow(false)
                // Deselect this to perform a clone without tags, saving time and disk space when you just want to access what is specified by the refspec.
                noTags(false)
                honorRefspec(false)
                reference("")
                timeout(10)
              }
            }            
            bitbucketTagDiscovery()
            // gitBranchDiscovery()
            localBranch() // Check out to matching local branch
            refSpecs {
              templates {
                refSpecTemplate {
                // A ref spec to fetch.
                  value("+master:@{remote}/master")
                }
              }
            }
          }
        }
      }
      strategy {
        allBranchesSame {}
      }
    }
  }
  factory {
    workflowBranchProjectFactory {
      // Relative location within the checkout of your Pipeline script.
      scriptPath("Jenkinsfile")
    }
  }
  triggers {
    bitbucketPush {
      buildOnCreatedBranch(true)
      overrideUrl("")
    }
    computedFolderWebHookTrigger {
      // The token to match with webhook token.
      token("bb_cloud_webhook_rim_DevOps_terraform_jenkins_platform_Kt8631XgQ55sw8")
    }        
  }
  orphanedItemStrategy {
    // Trims dead items by the number of days or the number of items.
    discardOldItems {
      // Sets the number of days to keep old items.
      daysToKeep(30)
    }
  }  
}


