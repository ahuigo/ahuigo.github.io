---
title: Go regex
date: 2019-10-02
private:
---
# Go regex
    var specialChars = regexp.MustCompile(`[{}/\\:\s.]`)

    func clean(value string) string {
        return specialChars.ReplaceAllString(value, "-")
    }
