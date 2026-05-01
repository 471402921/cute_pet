# Flutter convenience commands. Wraps `flutter pub` operations with the
# CN pub mirror so dependency resolution works without modifying ~/.zshrc.
# Run `make` (no args) to see the available targets.

PUB_MIRROR := PUB_HOSTED_URL=https://pub.flutter-io.cn FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn

.PHONY: help get upgrade outdated add run test analyze clean

help:
	@echo "Targets:"
	@echo "  make get             flutter pub get             (mirror)"
	@echo "  make upgrade         flutter pub upgrade         (mirror)"
	@echo "  make outdated        flutter pub outdated        (mirror)"
	@echo "  make add PKG=<name>  flutter pub add <name>      (mirror)"
	@echo "  make run             flutter run                 (mirror)"
	@echo "  make test            flutter test"
	@echo "  make analyze         flutter analyze"
	@echo "  make clean           flutter clean"

get:
	$(PUB_MIRROR) flutter pub get

upgrade:
	$(PUB_MIRROR) flutter pub upgrade

outdated:
	$(PUB_MIRROR) flutter pub outdated

add:
	@if [ -z "$(PKG)" ]; then echo "Usage: make add PKG=<package_name>"; exit 1; fi
	$(PUB_MIRROR) flutter pub add $(PKG)

run:
	$(PUB_MIRROR) flutter run

test:
	flutter test

analyze:
	flutter analyze

clean:
	flutter clean
