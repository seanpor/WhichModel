.PHONY: lint spell links clean help

PDF_INPUT  := recommendations-economist.md
PDF_OUTPUT := recommendations.pdf

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-12s\033[0m %s\n", $$1, $$2}'

$(PDF_OUTPUT): $(PDF_INPUT)
	pandoc $< \
		-f markdown \
		-t pdf \
		--pdf-engine=lualatex \
		--toc \
		--toc-depth=2 \
		-V geometry:margin=1in \
		-V fontsize=11pt \
		-V mainfont="Latin Modern Roman" \
		-V monofont="Latin Modern Mono" \
		-V colorlinks=true \
		-V linkcolor=blue \
		-V urlcolor=blue \
		-V header-includes='\usepackage{fancyhdr}\usepackage{booktabs}\usepackage{longtable}\pagestyle{fancy}\fancyhead[L]{AI Coding Cost Optimisation}\fancyhead[R]{\today}\fancyfoot[C]{}' \
		-o $@
	@echo "  Generated: $@"

pdf: $(PDF_OUTPUT) ## Generate PDF from markdown

lint: spell links ## Run all linters (markdown + spell + links)

spell: $(PDF_INPUT) ## Check spelling
	@echo "  Checking spelling..."
	@aspell --mode=markdown --lang=en_GB --personal=./.aspell.en.pws list < $< | sort -u | \
		if [ "$$(cat)" = "" ]; then \
			echo "  Spelling OK"; \
		else \
			echo "  Misspelled words:"; \
			aspell --mode=markdown --lang=en_GB --personal=./.aspell.en.pws list < $< | sort -u; \
			exit 1; \
		fi

links: $(PDF_INPUT) ## Check for broken URLs
	@echo "  Checking links..."
	@grep -oP 'https?://[^\s\)]+' $< | while read url; do \
		if curl -sf -o /dev/null -m 5 "$$url" 2>/dev/null; then \
			echo "    OK: $$url"; \
		else \
			echo "    BROKEN: $$url"; \
			BROKEN=1; \
		fi; \
	done
	@if [ "$$BROKEN" = "1" ]; then exit 1; fi
	@echo "  Links OK"

clean: ## Remove generated files
	rm -f $(PDF_OUTPUT)
	@echo "  Cleaned"
