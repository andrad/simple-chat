var MessageSocket = function(user_id, theme_id, form) {
    this.user_id = user_id;
    this.theme_id = theme_id;
    this.form = $(form);

    this.socket = new WebSocket(App.websocket_url + 'themes/' + this.theme_id);

    this.init();
};

MessageSocket.prototype.init = function() {
    var _this = this;

    this.form.submit(function(e) {
        e.preventDefault();
        _this.sendMessage($('#message_message').val());
    });

    this.socket.onmessage = function(e) {
        var tokens = e.data.split("\n");
        switch(tokens[0]) {
            case 'messageok':
                _this.messageOk(tokens[1]);
                break;
            case 'messagefail':
                _this.messageFail(tokens[1]);
                break;
        };
        console.log(e);
    };
};

MessageSocket.prototype.sendMessage = function (value) {
    this.value = value;
    var template = "message\n{{user_id}}\n{{theme_id}}\n{{value}}";
    this.socket.send(Mustache.render(template, {
        user_id: this.user_id,
        theme_id: this.theme_id,
        value: value
    }));
};

MessageSocket.prototype.messageOk = function (value) {
    console.log('OK: ' + value);
    $('p.message:last').after(value);
};

MessageSocket.prototype.messageFail = function (value) {
    console.log('Fail: ' + value);
};