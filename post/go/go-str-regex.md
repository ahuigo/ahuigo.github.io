---
title: Go regex
date: 2019-10-02
private:
---
# Go regex

## replace
    var specialChars = regexp.MustCompile(`[{}/\\:\s.]`)

    func clean(text string) string {
        return specialChars.ReplaceAllString(text, "-")
    }

## match
    if !regexp.MustCompile(`^/api/v1/(a|b)/`).MatchString(resource) {
    }
