YB_TAR_NAME = yugabyte-$(YB_VERSION)-b$(YB_BUILD_NO)-linux-x86_64.tar.gz
YB_DOWNLOADS_BASE = https://downloads.yugabyte.com
YB_BINARY_URL = $(YB_DOWNLOADS_BASE)/releases/$(YB_VERSION)/$(YB_TAR_NAME)

download:
	@if [ ! -f build/$(YB_TAR_NAME) ]; then \
		echo "Downloading YugaByte release tars for the version $(YB_VERSION)"; \
		dnf install -y wget || true; \
		wget --progress "dot:giga" --directory-prefix "build" $(YB_BINARY_URL); \
	fi

prepare: download
	@if [ ! -d build/yugabytedb_extracted ]; then \
		echo "Extracting the release tar '$(YB_TAR_NAME)' for yugabytedb package."; \
		mkdir -p build/yugabytedb_extracted; \
		tar -xzf build/$(YB_TAR_NAME) -C build/yugabytedb_extracted --strip-components 1; \
	else \
		echo "Re-extracting the release tar '$(YB_TAR_NAME)' for yugabytedb package."; \
		rm -rf build/yugabytedb_extracted; \
		mkdir -p build/yugabytedb_extracted; \
		tar -xzf build/$(YB_TAR_NAME) -C build/yugabytedb_extracted --strip-components 1; \
	fi

rpm: prepare
	@echo "Building RPM package for yugabytedb version '$(YB_VERSION)', revision '$(YB_RPM_REVISION)'"; \
	nfpm package -p rpm -t build/
