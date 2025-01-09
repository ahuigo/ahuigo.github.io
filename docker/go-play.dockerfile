from golang:1.22-alpine
WORKDIR /app
RUN go mod init m
RUN echo $'cat - > main.go \n\
if grep "func Test" main.go >/dev/null; then \
    mv main.go a_test.go && go mod tidy && go test -v a_test.go; \
else \
    go run .\
fi' > /run.sh
CMD sh /run.sh

## usage###
#docker build -t go1.22 .
#docker run --rm -it go1.22 sh
#cat a.go | docker run --rm -i  go1.22 
