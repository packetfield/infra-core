#!/usr/bin/env python

from jinja2 import Template
import fnmatch
import os
import sys

# the plan...

## drone-ci runs this step..
## on develop (I think? TODO: debate which branch of this repo to trigger this on)
##  ....maybe when there is a special tag?
## indexes for config-${ENV}.tfvars
## notes which components
## if there exists a respective ansible/playbook/${COMPONENT}.yml +include make config stage
## - generates configs which will create the jobs (in yml)
## - puts said configs into a git repo

## gocd can load the remote config from git
## EG:

#  <config-repo pluginId="yaml.config.plugin" id="automatic-lua-property-tables">
#    <git url="https://github.com/d-led/automatic-lua-property-tables.git" />
#  </config-repo>

## sample config: https://github.com/d-led/automatic-lua-property-tables/blob/master/ci.gocd.yaml




def find_files(dir, string):
    matches = []
    for root, dirnames, filenames in os.walk(dir):
        for filename in fnmatch.filter(filenames, string):
            matches.append(os.path.join(root, filename))
    return matches


environments = [ 'shared', 'develop', 'master' ]


## create a list of files that are config-*.tfvars
tfvars = []
for env in environments:
    # print('scanning for ' + env)
    result = find_files('terraform', 'config-{}.tfvars'.format(env))
    for fn in result:
        tfvars.append(fn)


playbook_search = find_files('ansible/playbooks', '*.yml')
playbooks = []
for book in playbook_search:
    book = (book).split("/")[2].split(".yml")[0]
    playbooks.append(book)

def render_header():
    ta = Template(
"""---
#ci.gocd.yaml
# See: https://github.com/tomzo/gocd-yaml-config-plugin
format_version: 2
pipelines:
""")
    print(ta.render())



def render_pipe(env, component, branch, has_playbook):
    repo = "https://github.com/packetfield/infra-core.git"
    group = "ops-{}".format(env)

    t = Template(
"""
  {{ job_name }}:
    group: {{ group }}
    label_template: "${mygit[:8]}"
    lock_behavior: unlockWhenFinished
    materials:
      mygit:
        git: {{ repo }}
        branch: {{ branch }}

    timer:
      spec: "0 0 11 ? * MON-FRI"  #mon-fri 11AM (office hours)
    stages:
      - deps:
          clean_workspace: false
          jobs:
            deps:
              tasks:
               - exec:
                   command: /bin/bash
                   arguments:
                    - bin/gocd-helper
                    - deps
      - apply:
          clean_workspace: false
          jobs:
            apply:
              tasks:
               - exec:
                   command: /bin/bash
                   arguments:
                    - bin/gocd-helper
                    - make
                    - ENV={{ env }}
                    - COMPONENT={{ component }}
                    - plan

{% if has_playbook == True %}
      - config:
          clean_workspace: false
          jobs:
            config:
              tasks:
               - exec:
                   command: /bin/bash
                   arguments:
                    - bin/gocd-helper
                    - make
                    - ENV={{ env }}
                    - COMPONENT={{ component }}
                    - config
{% endif %}


"""
    )
    print(t.render(
        env=env,
        repo=repo,
        branch=branch,
        group=group,
        component=component,
        has_playbook=has_playbook,
        job_name="{}-{}".format(branch, component)
        ))


render_header()

targets = {}
for tfvar in tfvars:
    component = tfvar.split("/")[1]
    env = tfvar.split("/")[2].split(".")[0].split("-")[1]


    if env == "shared":
        if component in playbooks:
            render_pipe("shared", component, "master", True)
        else:
            render_pipe("shared", component, "master", False)
    else:
        if component in playbooks:
            render_pipe(env, component, env, True)
        else:
            render_pipe(env, component, env, False)

