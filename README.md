# Red Hat OpenShift Enterprise Project Exporter
## Back up the Project configurations for OpenShift Enterprise into a Git repository.
This script is going to create a back up of all your OpenShift Enterprise Projects
and their configurations into YAML format.  It'll then commit those YAML files
back into this Git repository.

Right now it needs to run under the root user because we need to log into
OpenShift automatically and not be prompted for credentials.  If you have another
method for logging in to OpenShift, definitely do that.

## Cron Job
Create a cron job like this...

0 1 * * * root <$EXPORT_DIR>/ose-project-export.sh > /dev/null

## Git User
You will need to provide access to this Git repository to your root user, likely
by setting up a new SSH key and adding it to your Github or private Git repo.

