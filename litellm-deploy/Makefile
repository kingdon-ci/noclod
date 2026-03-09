.PHONY: docker

docker:
	@mkdir -p $(shell pwd)/config_dir
	@cp $(shell pwd)/litellm_config.yaml $(shell pwd)/config_dir/config.yaml
	@container rm -f noclod-litellm 2>/dev/null || true
	container run --name noclod-litellm \
	--env-file env -v $(shell pwd)/config_dir:/app/config_dir \
	-p 4000:4000 \
	ghcr.io/berriai/litellm:main-stable \
	--config /app/config_dir/config.yaml --detailed_debug

# Do not overwrite env!
env:
	cp env.example env
