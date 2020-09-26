---
title: Go regex
date: 2019-10-02
private:
---
# Go wildcard
    import "path/filepath"

    fmt.Println(filepath.Match(`/home/*`, "/home/ahuigo"))


# Go regex
go-lib/str/regex.go

## replace
    var specialChars = regexp.MustCompile(`[{}/\\:\s.]`)

    func clean(text string) string {
        return specialChars.ReplaceAllString(text, "-")
    }

### replace with callback(FindAllSubmatchIndex)
    import "regexp"
    func ReplaceAllGroupFunc(re *regexp.Regexp, str string, repl func([]string) string) string {
        result := ""
        lastIndex := 0

        for _, v := range re.FindAllSubmatchIndex([]byte(str), -1) {
            groups := []string{}
            for i := 0; i < len(v); i += 2 {
                groups = append(groups, str[v[i]:v[i+1]])
            }

            result += str[lastIndex:v[0]] + repl(groups)
            lastIndex = v[1]
        }

        return result + str[lastIndex:]
    }

Example:

    str := "abc foo:bar def baz:qux ghi"
    re := regexp.MustCompile("([a-z]+):([a-z]+)")
    result := ReplaceAllGroupFunc(re, str, func(groups []string) string {
        return groups[1] + "." + groups[2]
    })
    fmt.Printf("'%s'\n", result)

## match
### matchString(bool)
    if regexp.MustCompile(`^/api/v1/(a|b)/`).MatchString(resource) {
    }

### FindStringSubmatch

    func main() {
        r := regexp.MustCompile(`^(?P<Year>\d{4})-(?P<Month>\d{2})-(?P<Day>\d{2})$`)

        res := r.FindStringSubmatch(`2015-05-27`)
        names := r.SubexpNames()
        for i, _ := range res {
            if i != 0 {
                fmt.Println(names[i], res[i])
            }
        }
    }
### FindAllStringSubmatch: array

    txt := `2001-01-20
    2009-03-22
    2018-02-25
    2018-06-07`

    regex := *regexp.MustCompile(`(?s)(\d{4})-(\d{2})-(\d{2})`)
    res := regex.FindAllStringSubmatch(txt, -1)
    for i := range res {
        //like Java: match.group(1), match.gropu(2), etc
        fmt.Printf("year: %s, month: %s, day: %s\n", res[i][1], res[i][2], res[i][3])
    }
