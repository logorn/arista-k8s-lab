# leafspine-report

A simple HTML report based on data retrieved from 3 commands and consolidated into a single report table per device.

The commands used are:

* show ip interface
* show ip bgp summary
* show lldp neighbor

These are retrieved through a single play.

Two further plays consolidate all the data into a single YAML data structure using the Jinga2 template data-yml.j2.  The resulting YAML is saved in the output directory.

The final 3 plays read in the YAML data, produce HTML snippets using Jinja2 templates.  A final Jinja2 template is used to combine each section of HTML with a header and footer to spit out a final report.html file.

The finals 3 plays can be ran seperately on the existing YAML files by using an ansible tag:

~~~~
vagrant@provisioner:/provisioning/leafspine-report$ ansible-playbook leafspine-report.yaml --tags reportonly

PLAY [Leaf-Spine Topology Report] **********************************************

TASK [Read in Device YAML Data] ************************************************
ok: [leaf-1]
ok: [leaf-2]
ok: [spine-1]
ok: [spine-2]

TASK [Produce Report Sections] *************************************************
ok: [spine-1]
ok: [leaf-2]
ok: [leaf-1]
ok: [spine-2]

TASK [Combine Report Sections] *************************************************
ok: [leaf-1]

PLAY RECAP *********************************************************************
leaf-1                     : ok=3    changed=0    unreachable=0    failed=0   
leaf-2                     : ok=2    changed=0    unreachable=0    failed=0   
spine-1                    : ok=2    changed=0    unreachable=0    failed=0   
spine-2                    : ok=2    changed=0    unreachable=0    failed=0   
~~~~

Likewise, there's a dataonly tag that only gathers data and spits out YAML.

Please note that the HTML has dependencies on some CSS/JS files in the "report" directory (and uses relative paths, so you'll need to clone the whole folder to see the sample report.

