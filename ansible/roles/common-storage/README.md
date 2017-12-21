# Overview

Takes care of mounting and formatting (if neccessary) volumes.

It will also run resize2fs every time (in case the disk has been grown)

Please override these variables with your own dictionary..


## example playbook
```
---
- hosts: "tag_somehost"
  become: True
  vars:
    common_storage:
      - device: /dev/sdb
        mount:  /opt/stuff
        opts:   noatime
        owner:  root
        group:  root
        mode:   0750

  roles:
    - common_storage  #this role
    - my-role
```

See defaults/main.yml for notes
