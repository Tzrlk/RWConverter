'use strict';
let ParseTopic = require('./lib/parseTopic');
//let rwExport = require('./CarnageCon2016 (Player).3.rwoutput');
//let argv = require('minimist')(process.argv.slice(2));
let fs = require('fs');
let _ = require('lodash');
let parser = require('xml2json');
let html = require('./lib/templateHandler');
let Promise = require('bluebird');


function processExport(source) {
    writeHead(source.output.definition.details.name);
    buildNav(source.output.definition.details.name, source.output.contents.topic);
}

function buildNav(name, topics) {
    let headings = [];
    let categories = {};
    let links = '<li><a href="/">Home</a></li>';
    let heading ='';
    let tmpl = require('./templates/nav');
    let html;
    let RWTopic = new ParseTopic();

    topics.forEach(function (topic) {
        RWTopic.parse(topic);
        if(!categories[topic.category_name]) {
            categories[topic.category_name] = [];
        }
        categories[topic.category_name].push({name: topic.public_name, link: topic.topic_id});
    });

    // for(let i = 0; i < topics.length; i++) {
    //     RWTopic.parse(topics[i]);
    //     if(!categories[topics[i].category_name]) {
    //         categories[topics[i].category_name] = [];
    //     }
    //     categories[topics[i].category_name].push({name: topics[i].public_name, link: topics[i].topic_id});
    //     // if(!_.includes(headings,topics[i].category_name)) {
    //     //     headings.push(topics[i].category_name);
    //     // }
    // }

/* */
    let keys = Object.keys(categories);
    for (let key in categories) {
        let subs = categories[key];
        let menu = '';
        // console.log('key: ', key);
        heading += tmpl.heading(key, menu);
        for (let x = 0; x < subs.length; x++) {
            heading += tmpl.subMenu(subs[x].name, subs[x].link);
        }
        heading += '</ul>';
    }
    // console.log('heading: ', heading);
/* */

    // for(let x = 0; x < headings.length; x++) {
    //     links += `<li><a href="/${_.camelCase(headings[x].toLowerCase())}">${headings[x]}</a></li>`;
    // }

    html = tmpl.menu(heading);

    fs.writeFile("./views/partials/header.ejs", html, function(err) {
        if(err) {
            return console.log(err);
        }
    });
}

function writeHead(title) {
    let tmpl = require('./templates/head');
    let head = tmpl(title);
    // console.log('head: ', head);
    fs.writeFile("./views/partials/head.ejs", head, function(err) {
        if(err) {
            return console.log(err);
        }

    });
}


fs.readFile('CarnageCon2016 (Player).rwoutput', function (err, data) {
    if (err) {
        return console.log(err);
    }
    let output = JSON.parse(parser.toJson(data));
    fs.writeFile("./CarnageCon2016.json", JSON.stringify(output), function(err) {
        if(err) {
            return console.log(err);
        }

    });
    //console.log('json: ', parser.toJson(data));
    processExport(output);
})