'use strict';
let html = require('../lib/templateHandler');

const tmpl = content => `
    <div class="panel panel-default">
        <div class="panel-heading">
            CarnageCon2016
        </div>
        <div class="panel-body">
            ${content}
        </div>
    </div>
`;

module.exports = tmpl;

