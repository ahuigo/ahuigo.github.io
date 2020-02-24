---
title: Use generic in ts react
date: 2020-02-23
private: true
---
# Use generic in ts react
    interface IUser {
    name: string;
    }
    const [user, setUser] = useState<IUser>({name: 'Jon'});
