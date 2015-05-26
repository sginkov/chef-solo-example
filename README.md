# Installation steps to use chef scripts
 
See https://gist.github.com/sginkov/ed3fe2cb78fab07dff71

## Create custom cookbook

```bash
knife cookbook create sample_app -o site-cookbooks
```

## Deploy for Vagrant node

```bash
knife solo cook root@test -i ~/.vagrant.d/insecure_private_key
```
Test the application on http://test/