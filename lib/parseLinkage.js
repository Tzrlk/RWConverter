'use strict'; 
let _ = require('lodash');
class ParseLinkage {
    constructor() {

    }
}

ParseLinkage.render = function (links) {
    let inbound = '';
    let outbound = [];
    if(_.isPlainObject(links)) {
        links = [links];
    }
    for (var x = 0; x < links.length; x++) {
        let link = links[x];
        // console.log('link: ', link);
        // if (link.direction === 'Inbound') {
            inbound += `<li><a href="/${_.camelCase(link.target_name.toLowerCase())}">${link.target_name}</a></li>`;
        // }
        if (link.direction === 'Outbound') {
            outbound.push(link.target_name);           
        }

    }
    return [inbound, outbound];
}

module.exports = ParseLinkage;