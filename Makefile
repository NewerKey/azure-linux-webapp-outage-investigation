TF := terraform -chdir=terraform

.PHONY: check-env fmt init validate plan apply destroy

check-env:
	@test -n "$$ARM_SUBSCRIPTION_ID" || (echo "ARM_SUBSCRIPTION_ID not set" >&2; exit 1)

fmt:
	$(TF) fmt

init: check-env
	$(TF) init

validate: check-env
	$(TF) validate

plan: check-env
	$(TF) plan -out=tfplan

apply: check-env
	$(TF) apply tfplan

destroy: check-env
	$(TF) destroy
