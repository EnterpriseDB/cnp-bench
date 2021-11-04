.DEFAULT_GOAL := help

# Credits: https://gist.github.com/prwhite/8168133
.PHONY: help
help: ## Prints help command output
	@awk 'BEGIN {FS = ":.*##"; printf "\ncnp-bench CLI\nUsage:\n"} /^[$$()% 0-9a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-30s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

.PHONY: generate-schemas
generate-schema: ## Updates the auto-generated charts values.schema.json
	@helm schema-gen pgbench-benchmark/values.yaml > pgbench-benchmark/values.schema.json
	@helm schema-gen fio-benchmark/values.yaml > fio-benchmark/values.schema.json
	@helm schema-gen cnp-loadbalancer/values.yaml > cnp-loadbalancer/values.schema.json
	@echo "Validation schemas generated"

.PHONY: generate-docs
generate-docs: ## Updates the auto-generated charts README.md
	@helm-docs || (echo "Please, install https://github.com/norwoodj/helm-docs first" && exit 1)
