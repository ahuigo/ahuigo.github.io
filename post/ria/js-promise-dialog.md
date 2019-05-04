---
title: Js Promise dialog
date: 2019-04-30
---
# Js Promise dialog
参考：https://jsbin.com/fucofu/edit?html,js,output

give it a id

    <script>
    function promptPromise(message) {
      var dialog       = document.getElementById('dialog');
      var input        = dialog.querySelector('input');
      var okButton     = dialog.querySelector('button.ok');

      dialog.querySelector('.message').innerHTML = String(message);
      dialog.className = '';

      return new Promise(function(resolve, reject) {
        dialog.addEventListener('click', function handleButtonClicks(e) {
          if (e.target.tagName !== 'BUTTON') { return; }
          dialog.removeEventListener('click', handleButtonClicks);
          dialog.className = 'hidden';
          if (e.target === okButton) {
            resolve(input.value);
          } else {
            reject(new Error('User cancelled'));
          }
        });
      });
    }

    document.addEventListener('DOMContentLoaded', function() {
      var button = document.getElementById('action');
      var output = document.getElementById('prompt');
      button.addEventListener('click', function() {
        promptPromise('What is your name?').then(function(name) {
          output.innerHTML = '' + name;
        })
        .catch(function() {
          output.innerHTML = '¯\\_(ツ)_/¯';
        });
      });
    });
    </script>
    <!DOCTYPE html>
    <html lang="en">
    <head>
      <meta charset="UTF-8">
      <title>Async Dislogs Example</title>
      <script src="//cdn.jsdelivr.net/bluebird/3.0.5/bluebird.js"></script>
      <script type="text/javascript">
        document.addEventListener('DOMContentLoaded', function() {
          var time = document.getElementById('time-stamp');
          clockTick();
          setInterval(clockTick, 1000);
          function clockTick() {
            time.innerHTML = '' + new Date();
          }
        });
      </script>
      <style type="text/css">
        #dialog {
          width: 200px;
          margin: auto;
          border: thin solid black;
          padding: 10px;
          background: lightgreen;
        }
        .hidden {
          display: none;
        }
      </style>
    </head>
    <body>
      <p>The current time is <span id="time-stamp"></span>.</p>
      <p>Your name is <span id="prompt"></span>.</p>
      <button id="action">Set Name</button>
      <div id="dialog" class="hidden">
        <div class="message">foobar</div>
        <input type="text">
        <div>
          <button class="ok">Ok</button>
          <button class="cancel">Cancel</button>
        </div>
      </div>
    </body>
    </html>
