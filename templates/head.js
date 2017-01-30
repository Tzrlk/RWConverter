'use strict';
let html = require('../lib/templateHandler');

const tmpl = title => `
    <meta charset="UTF-8">
    <title>${title}</title>
    <link rel="stylesheet" href="//maxcdn.bootstrapcdn.com/bootstrap/3.2.0/css/bootstrap.min.css">
    <link href="//maxcdn.bootstrapcdn.com/font-awesome/4.2.0/css/font-awesome.min.css" rel="stylesheet">
    <link rel="stylesheet" type="text/css" href="main.css">

    <meta name="googlebot" content="noindex">
`;

module.exports = tmpl;