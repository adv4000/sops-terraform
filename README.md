# SOPS - Secrets OPerationS

ENCRYPT Secret YAML file using AWS KMS Key:
```
sops --kms arn:aws:kms:ca-west-1:827611452653:key/064f616f-1a84-4768-a93f  \
     --encrypt secrets-sops.yml > secrets-sops.encrypted.yml
```

DECRYPT Secret YAML file:
```
sops --decrypt secrets-sops.encrypted.yml > secrets-sops.decrypted.yml
```


URLS:
* https://getsops.io                             
* https://github.com/getsops/sops  
* https://registry.terraform.io/providers/carlpett/sops

Copyleft &copy; by Denis Astahov 2025.