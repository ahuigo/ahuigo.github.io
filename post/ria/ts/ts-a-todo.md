    function buildName({firstName = 'Tom', lastName=''}:{firstName:string, lastName:string}={}) {
        return firstName + ' ' + lastName;
    }