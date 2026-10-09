python3 -c "
with open('Documents/scap/remediation-playbook.yml', 'r') as f:
    content = f.read()
content = content.replace('community.general.ini_file', 'ini_file')
content = content.replace('ansible.builtin.ini_file', 'ini_file')
with open('Documents/scap/remediation-playbook3.yml', 'w') as f:
    f.write(content)
"