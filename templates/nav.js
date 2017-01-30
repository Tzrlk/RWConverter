'use strict';
let html = require('../lib/templateHandler');
let _ = require('lodash');

const menu = nav => `<div class="nav-side-menu">
    <i class="fa fa-bars fa-2x toggle-btn" data-toggle="collapse" data-target="#menu-content"></i>
  
        <div class="menu-list">
            <ul id="menu-content" class="menu-content collapse out">  
                ${nav}
            </ul>
     </div>
</div>`;

const heading = (name, _subMenu) => `
<li  data-toggle="collapse" data-target="#${_.camelCase(name.toLowerCase())}" class="collapsed active">
                  <a href="#"> ${name} <span class="arrow"></span></a>
                </li>
                <ul class="sub-menu collapse" id="${_.camelCase(name.toLowerCase())}">`;

const subMenu = (name, link) => `
    <li><a href="/topic/${link}">${name}</a></li>
`;

module.exports = {menu: menu, heading: heading, subMenu: subMenu};
/*
`<div class="nav-side-menu">
    <i class="fa fa-bars fa-2x toggle-btn" data-toggle="collapse" data-target="#menu-content"></i>
  
        <div class="menu-list">
  
            <ul id="menu-content" class="menu-content collapse out">
                <li  data-toggle="collapse" data-target="#products" class="collapsed active">
                  <a href="#"><i class="fa fa-gift fa-lg"></i> UI Elements <span class="arrow"></span></a>
                </li>
                <ul class="sub-menu collapse" id="products">
                    <li class="active"><a href="#">CSS3 Animation</a></li>
                    <li><a href="#">General</a></li>
                    <li><a href="#">Buttons</a></li>
                    <li><a href="#">Tabs & Accordions</a></li>
                    <li><a href="#">Typography</a></li>
                    <li><a href="#">FontAwesome</a></li>
                    <li><a href="#">Slider</a></li>
                    <li><a href="#">Panels</a></li>
                    <li><a href="#">Widgets</a></li>
                    <li><a href="#">Bootstrap Model</a></li>
                </ul>
            </ul>
     </div>
</div>`;

`
    <nav class="navbar navbar-default" role="navigation">
    <div class="container-fluid">

        <div class="navbar-header">
            <a class="navbar-brand" href="#">
                <span class="glyphicon glyphicon glyphicon-tree-deciduous"></span>
                ${name}
            </a>
        </div>

        <ul class="nav navbar-nav">
            ${links}
        </ul>
      
    </div>
    </nav>
`
*/