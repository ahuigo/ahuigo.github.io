---
title: ts type class
date: 2020-06-16
private: true
---
# ts type class

    export class Clock extends Component<{name:string}, {time: Date}> {
      tick() {
        this.setState({
          time: new Date()
        });
      }
    }

    <Clock name="China"/>