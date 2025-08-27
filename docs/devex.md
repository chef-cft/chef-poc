# Demonstrate the Developer Experience (Code Operations)

## Install Chef Workstation

Download and install the Chef Workstation (Developer Kit)

- macOS / Linux Installer: `curl -L https://chefdownload-commercial.chef.io/install.sh?license_id=tmns-7ccf0526-f679-45a6-9878-c022c5f93601-6104 | sudo bash -s -- -P chef-workstation`
- Windows Installer: `. { iwr -useb https://chefdownload-commercial.chef.io/install.ps1?license_id=tmns-7ccf0526-f679-45a6-9878-c022c5f93601-6104 } | iex; install -project chef-workstation`

- [Windows 10](https://chefdownload-commerical.chef.io/stable/chef-workstation/download?eol=true&license_id=tmns-7ccf0526-f679-45a6-9878-c022c5f93601-6104&m=x86_64&p=windows&pv=10&v=25.5.1084)
- [macOS 14](https://chefdownload-commerical.chef.io/stable/chef-workstation/download?eol=true&license_id=tmns-7ccf0526-f679-45a6-9878-c022c5f93601-6104&m=aarch64&p=mac_os_x&pv=14&v=25.5.1084)
- [Linux 2204 / WSL](https://chefdownload-commerical.chef.io/stable/chef-workstation/download?eol=true&license_id=tmns-7ccf0526-f679-45a6-9878-c022c5f93601-6104&m=x86_64&p=ubuntu&pv=22.04&v=25.5.1084)

## Configure Workstation to connect to the PoC Environment

Create the ~/.chef/credentials file with

```sh
[default]
client_name = "pang-admin"
client_key = "~/.chef/pang-admin.pem"
chef_server_url = "https://pang.demo.chef.io/organizations/demo"
chef_server_root = "https://pang.demo.chef.io/"
cookbook_path = ['~/chef-repo']
```

> We will all use the pang-admin user object for now. This will grant Admin privileges of the Org. We will talk about Orgs later.

1. Create pang-admin.pem key with the key provided by Solution Architect
2. Test the connectivity with `knife ssl fetch` and `knife ssl check`.
3. We'll come back to this shortly.

### Setup Podman with Docker Sockets

This is a magic script that should install Podman on a fresh Ubuntu 24.04 image:

```sh
curl -O https://raw.githubusercontent.com/chef-cft/chef-poc/refs/heads/main/setup_podman_ubuntu24.sh
chmod +x setup_podman_ubuntu24.sh
./setup_podman_ubuntu24
```

## Create a chef-repo

> Generally when folks start out, the simplest manner to begin with Chef is to create a local "chef-repo". This will hold a set of cookbooks that can be used for publishing. Typically when we get to enterprise level, other patterns are considered and used. We've discussed single repo and multiple repo scenerios during some demos. Personally, I like to create a `~/repos/` folder and in that create a folder for each GitHub org that I work with. I'll then clone the repo into it's parent org folder.

1. To create a repo in your home folder, `cd ~/`
2. Execute `chef generate repo chef-repo`. This creates a generic chef-repository in your home dir. Accept the license. NOTE: This is a Trial license and only applies during this PoC period.
3. Let's take a look at what is in there. This will be easiest if we open that folder in 

## Pull down a cookbook from Github

> This requires Git SCM to be installed on your workstation. You can skip this if you don't have it.

1. In your chef-repo/cookbooks directory, let's do a `git clone https://github.com/snohio/apache2`
2. Let's walk through this simple cookbook.

## Create a cookbook

> Again, using the Chef Workstation tool that can generate content, let's create a cookbook. Typically at Enterprise level we would recommend using your own templates, either in GitHub or creating one to generate from.

1. In your cookbook, let's create a cookbook called httpd with `chef generate cookbook httpd_name --kitchen dokken`
2. The -kitchen dokken sets up our kitchen.yml file for the dokken driver.
3. Using CoPilot or reviewing the coobook at [httpd](httpd/recipes/httpd.rb) create a recipe that installs httpd. You can select one OS or use the attributes to select the OS.
4. Update the /test/integration/default_test.rb to match the [default_test](httpd/test/integration/default_test.rb)
5. We are going to come back to this cookbook in Compliance CIS Operations in a few days.
6. We'll come back to testing shortly

### Supermarket and Dependencies

We have a public [Supermarket](https://supermarket.chef.io/) with cookbooks already set to be used as dependencies. This can happen a number of ways. Let's walk through one of my cookbooks called [diiv](https://github.com/snohio/diiv).

> The most important file is the metadata.rb file. This is used for versioning cookbooks, declaring dependencies, and cookbook header information.

## All About Attributes

1. Show some examples of attributes using [snohio](https://snohio.azure.chef-demo.com).
2. Walk through [Attribute Precedence](https://docs.chef.io/attribute_precedence/)
3. Create a File Attribute in our Attributes Folder for port number
4. Create a cookbook attribute in our recipe
5. Create an attrinute in our policyfile.
6. Create an attribute in our kitchen.yml

> We will look at Attributes at the Node / Operational level later. The imporant part is to understand how extensive they are.

### Adding Tags

Tags a a great way to identify systems in an indexable / searchable / filterable manner. They are a special type of Attribute that can be added and removed as a part of a recipe or managed at the Node level.

1. Write a tag if httpd or nginx or apache
2. Use a tag to write output and Untag.
3. Set a tag in the kitchen.yml

## Cookstyle Linting

Cookstyle is Chef's linting tool. It can be used to validate code locally, used in a pipeline, and also can be utilized to automatically fix common style and syntax issues. It is based on Rubocop.

1. Run `cookstyle` from your directory.
2. If there are errors, run `cookstyle -a` to fix what it can.
3. Add the Chef Infra Extensions to VScode for inline linting and autocompletion

## Integration Testing

While, as with Puppet, you can write rspec for unit testing, often times it is over and above what needs to be done in a simple manner. At the heart of Chef is our product called **InSpec**. This is a testing tool at it's heart. It is designed to be human readable and outcome testing - reporting true or false / pass or fail. A collection of InSpec resources can be put together to build a Compliance Profile. We'll get into that later.

In order to utilize InSpec to test, we need to build a sandbox environment based on the OS needed, run the cookbook and then verify against the test that we wrote.

Typically we want to keep the integration tests to just validate the outcomes, but as we build profiles, we can create tests for production items and generate reports prior to enforcing the configuration. Just a reminder that Chef is *extremely* flexible and the "how to implement" can take on all forms.

1. Update the existing test/integration/default_test to remove the skips.
2. Configure our kitchen.yml to use dokken as we built. Refer to [kitchen.yml](httpd/kitchen.yml)
3. We can play with Azure if the configuration gets set up. When working with Windows, you will need to use Azure, or Vagrant/Virtual Box, EC2 or any of the other drivers.

## Publishing Cookbooks

We're just going to have a discussion around this for now. There are two primary ways to use Chef. One is more secure and ensures that what you are running on your system is what is supposed to run on your system. This is Policyfiles, and generally it is our best practice. The other method is an older method that we term "Roles and Environments". This way is generally more flexible, allowing adhoc cookbook execution, adding or removing single cookbooks from run lists, applying attributes at a role or environment level. The downside to this method is that cookbook order can be tricky to maintain and your pipeline needs to manage the version pinning in the environment.

We should focus on utilizing Policyfiles for this PoC, however deeper dives and determinations should be detailed with the ProServe engagement.

1. Let's create a policyfile to push your httpd cookbook to the Chef Infra server.
2. run `chef install policy.rb`
3. run `chef push yourname policy.lock.json`

This cookbook (or group of cookbooks and runlist) has been published on the Chef Infra / DSM server.

You can reference my [policfiles](https://github.com/snohio/policyfiles) for examples of how to point to GitHub repos to pull cookbooks.

1. Quick discussion on the `berks` model in case it is determined to be the proper solution. 
2. `knife cookbook upload`

## Wrap up / QA Developer Experience

Now is your chance to ask anything additional that we might not have covered around development.

## Development Documentation Links

[Chef Workstation](https://docs.chef.io/workstation/)
[Attributes](https://docs.chef.io/attributes/)
[Infra Resources](https://docs.chef.io/resource/)
[Full List of Infra Resources](https://docs.chef.io/resources/)
[Checking Platforms](https://docs.chef.io/infra_language/checking_platforms/)
[Secrets](https://docs.chef.io/infra_language/secrets/)
[windows_ad_join](https://docs.chef.io/resources/windows_ad_join/)

---
[Return to README.md](README.md)
