SERVICE_NAME       := codebase-go-rest-lite
SERVICE_PORT       := 3000
IMAGE_NAME         := codebase-go-rest-lite
IMAGE_TAG          := latest
REBASE_URL         := "github.com/dimaskiddo/codebase-go-rest-lite"
COMMIT_MSG         := "update improvement"

.PHONY:

.SILENT:

init:
	make clean
	dep init -v

init-dist:
	mkdir -p dist
	touch dist/.gitkeep

ensure:
	make clean
	dep ensure -v

release:
	make ensure
	goreleaser --snapshot --skip-publish --rm-dist
	make init-dist
	echo "Build complete please check dist directory."

publish:
	GITHUB_TOKEN=$(GITHUB_TOKEN) gorelease --rm-dist
	make init-dist

run:
	go run *.go

clean:
	rm -rf ./dist/*
	make init-dist
	rm -rf ./vendor

commit:
	make ensure
	make clean
	git add .
	git commit -am "$(COMMIT_MSG)"

rebase:
	rm -rf .git
	find . -type f -iname "*.go*" -exec sed -i '' -e "s%github.com/dimaskiddo/codebase-go-rest-lite%$(REBASE_URL)%g" {} \;
	git init
	git remote add origin https://$(REBASE_URL).git

push:
	git push origin master

pull:
	git pull origin master

c-build:
	docker build -t $(IMAGE_NAME):$(IMAGE_TAG) --build-arg SERVICE_NAME=$(SERVICE_NAME) .

c-run:
	docker run -d -p $(SERVICE_PORT):$(SERVICE_PORT) --name $(SERVICE_NAME) --rm $(IMAGE_NAME):$(IMAGE_TAG)
	make c-logs

c-shell:
	docker exec -it $(SERVICE_NAME) bash

c-stop:
	docker stop $(SERVICE_NAME)

c-logs:
	docker logs $(SERVICE_NAME)

c-push:
	docker push $(IMAGE_NAME):$(IMAGE_TAG)

c-clean:
	docker rmi -f $(IMAGE_NAME):$(IMAGE_TAG)
