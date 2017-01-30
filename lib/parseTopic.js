'use strict';
let _ = require('lodash');
let Promise = require('bluebird');

let parseLinkage = require('./parseLinkage');
class ParseTopic {
    constructor() {
        this.monkey = function() {
            console.log('monkey');
        }
    }

    parse(topic) {
        let name = topic.public_name;
        let category = topic.category_name;
        let section = topic.section;
        let linkage;
        let inbound;
        let outbound;
        let secArr = [];

        let html = '';

        if (topic.linkage) {
            linkage = parseLinkage.render(topic.linkage);
            inbound = linkage[0];
            outbound = linkage[1];
        }

        if(_.isPlainObject(section)) {
            section = [section];
        }
        for (let _section of section) {
            secArr.push(ParseSection.parse(_section))
            // con÷sole.log(_section);
        }        
        Promise.all(secArr).then(function(x) {
            console.log('x: ', x);
        })
    }
}


ParseTopic.blargh = function() {
    console.log('blargh');
}

class ParseSection {
}

ParseSection.parse = function(section) {
    return new Promise(function (resolve, reject) {
        let tmp = `        
            <div class="panel-body">
            <h3>${section.name}</h3>
        `;
        tmp = tmp.replace(/(\r\n|\n|\r)/gm,"");
        return resolve(tmp.trim());
    })
}

module.exports = ParseTopic;
// export default ParseTopic;