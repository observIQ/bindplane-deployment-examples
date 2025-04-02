## Development Documentation

### Required Tools

- [Terraform](https://www.terraform.io/downloads.html)
- [Google Cloud SDK](https://cloud.google.com/sdk/docs/install)
- [Google CFT CLI](https://pkg.go.dev/github.com/GoogleCloudPlatform/cloud-foundation-toolkit/cli/bpmetadata)

### Metadata Generation

The `metadata.yaml` and `metadata.display.yaml` files were generated using the Google CFT CLI. This tool helps in managing and deploying configurations on Google Cloud Platform.

Example: 

```bash
cft blueprint metadata -p ./ -q -d --nested=false
```

### Packer Compute Images

The Packer compute images are built and published as part of the Bindplane release process. These images are used to ensure consistency and reliability across deployments.
