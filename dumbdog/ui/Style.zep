/**
 * Dumb Dog style builder
 *
 * @package     DumbDog\Ui\Style
 * @author 		Mike Welsh
 * @copyright   2023 Mike Welsh
 * @version     0.0.1
 *
 * Copyright 2023 Mike Welsh
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Library General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Library General Public License for more details.
 *
 * You should have received a copy of the GNU Library General Public
 * License along with this library; if not, write to the
 * Free Software Foundation, Inc., 51 Franklin St, Fifth Floor,
 * Boston, MA  02110-1301, USA.
*/
namespace DumbDog\Ui;

class Style
{
    public function __construct(object cfg)
    {
        //
    }

    public function build()
    {
        return this->defaultStyle();
    }

    private function defaultStyle()
    {
        return "<style>
        :root {
            /* Body */
            --body-background-colour: #92ddd6;
            --body-text-colour: #030202;
        
            /* Box */
            --box-background-colour: #fff;
            --box-success-background-colour: #1FD4AF;
            --box-active-background-colour: #71C2FF;
            --box-deleted-background-colour: #8B8B8B;
            --box-disabled-background-colour: #c2c2c2;
            --box-warning-background-colour: #F08966;
            --box-border-colour: #030202;
            --box-title-background-colour: #EB9691;
            --box-title-border-colour: #030202;
            --box-shadow: rgba(0, 0, 0, 0.1) 0px 20px 25px -5px, rgba(0, 0, 0, 0.04) 0px 10px 10px -5px;
        
            /* Buttons */
            --button-background-colour: #EB9691;
            --button-background-colour-disabled: #c9c9c9;
            --button-hover-background-colour: #fca8a4;
            --button-border-colour: #030202;
            --button-svg-fill-colour: #030202;
            --button-text-colour: #030202;
            --button-shadow: rgba(0, 0, 0, 0.1) 0px 20px 25px -5px, rgba(0, 0, 0, 0.04) 0px 10px 10px -5px;
        
            /* Inputs */
            --input-border-colour: #030202;
            --input-border-focus-colour: #fca8a4;
        
            /* Text */
            --text-heading-background-colour: #fff;
            --text-heading-border-colour: #030202;
            --text-heading-shadow: rgba(0, 0, 0, 0.1) 0px 20px 25px -5px, rgba(0, 0, 0, 0.04) 0px 10px 10px -5px;
            --text-required-colour: #fca8a4;
            --text-disabled: #a2a2a2;
            --text-deleted: #f44f46;
        } " . this->tagify() . "
        
        /* Fonts */
        @font-face {
            font-family: 'heading';
            src: url('/assets/heading.ttf') format('truetype');
        }
        @font-face {
            font-family: 'subheading';
            src: url('/assets/body.ttf') format('truetype');
        }
        html, body {
            color: var(--body-text-colour);
            font-family: Helvetica, sans-serif;
            height: 100vh;
            width: 100%;
            margin: 0;
            padding: 0;
            overflow-x: hidden;
        }
        body {
            display: flex;
            flex-direction: row;
            align-items: flex-start;
            width:100%;
            overflow-x: hidden;
        }
        a, a:hover, a:visited {
            color: var(--body-text-colour);
            text-decoration: none;
        }
        a:hover {
            text-decoration: underline;
        }
        .button:hover, .mini:hover {
            text-decoration: none;
        }
        /* Backgrounds */
        .background-image {
            position: fixed;
            bottom: 0;
            right: 0;
            width: 1200px;
            height: 1200px;
            overflow: hidden;
            background-image: url('/assets/backgrounds.jpg?t=" . time() . "');
            background-repeat: no-repeat;
            background-attachment: fixed;
        }
        #bk, #dashboard-bk {
            background-color: #92ddd6;
        }
        #bk .background-image, #dashboard-bk .background-image {
            background-position: bottom 0px right -13200px;
        }
        #page-bk {
            background-color: #3c6794;
        }
        #page-bk .background-image {
            background-position: bottom 0px right -12000px;
        }
        #events-bk {
            background-color: #67cbda;
        }
        #events-bk .background-image {
            background-position: bottom 0px right -10800px;
        }
        #appointments-bk {
            background-color: #25B5B6;
        }
        #appointments-bk .background-image {
            background-position: bottom 0px right -9600px;
        }
        #products-bk {
            background-color: #fbdee3;
        }
        #products-bk .background-image {
            background-position: bottom 0px right -8400px;
        }
        #settings-bk {
            background-color: #C7D9E5;
        }
        #settings-bk .background-image {
            background-position: bottom 0px right -7200px;
        }
        #templates-bk {
            background-color: #597566;
        }
        #templates-bk .background-image {
            background-position: bottom 0px right -6000px;
        }
        #themes-bk {
            background-color: #B4B5BA;
        }
        #themes-bk .background-image {
            background-position: bottom 0px right -4800px;
        }
        #users-bk {
            background-color: #f5ded6;
        }
        #users-bk .background-image {
            background-position: bottom 0px right -3600px;
        }
        #page-not-found {
            background-color: #fff;
        }
        #page-not-found .background-image {
            background-position: bottom 0px right -2400px;
        }
        #error {
            background-color: #92ddd6;
        }
        #error .background-image {
            background-position: bottom 0px right -1200px;
        }
        #orders-bk {
            background-color: #506eb6;
        }
        #orders-bk .background-image {
            background-position: bottom 0px right 0px;
        }        
        main {
            position: relative;
            margin: 0 auto;
            width: 100%;
            max-width: 1200px;
            z-index: 2;
            padding: 60px 0px;
            display: flex;
            flex-direction: column;
        }

        /* Inputs */
        .input-group {
            display: flex;
            flex-direction: column;
            flex: 100%;
            margin-bottom: 30px;
        }
        .input-group > span {
            font-family: 'subheading', Helvetica, sans-serif;
            font-size: 56pt;
            line-height: 44pt;
        }
        input, textarea, select, .trumbowyg-editor, td {
            font-family: Helvetica, sans-serif !important;
            font-size: 14pt !important;
        }
        input, textarea, select {
            padding: 10px;
        }
        .trumbowyg-editor,
        .trumbowyg-editor input,
        .trumbowyg-editor button,
        .trumbowyg-dropdown-link button,
        .trumbowyg-dropdown-formatting button,
        .trumbowyg-editor h1,
        .trumbowyg-editor h2,
        .trumbowyg-editor h3,
        .trumbowyg-editor h4,
        .trumbowyg-editor h5,
        .trumbowyg-editor h6,
        .trumbowyg-editor span {
            line-height: 14pt !important;
            font-family: Helvetica, sans-serif !important;
            margin: 0 !important;
        }
        .trumbowyg-editor h1,
        .trumbowyg-editor h2,
        .trumbowyg-editor h3,
        .trumbowyg-editor h4,
        .trumbowyg-editor h5,
        .trumbowyg-editor h6 {
            margin: 5px 0 !important;
        }
        .trumbowyg-editor h1 {
            font-size: 1.6em;
            line-height: 1.6em !important;
        }
        .trumbowyg-editor h2 {
            font-size: 1.5em;
            line-height: 1.5em !important;
        }
        .trumbowyg-editor h3 {
            font-size: 1.4em;
            line-height: 1.4em !important;
        }
        .trumbowyg-editor h4 {
            font-size: 1.3em;
            line-height: 1.3em !important;
        }
        .trumbowyg-editor h5 {
            font-size: 1.2em;
            line-height: 1.2em !important;
        }
        .trumbowyg-editor h6 {
            font-size: 1.1em;
            line-height: 1.1em !important;
        }
        .trumbowyg-dropdown-link button,
        .trumbowyg-dropdown-formatting button {
            line-height: 35px !important;
        }
        input:focus, textarea:focus, select:focus {
            border:1px solid var(--input-border-focus-colour);
            outline: none;
            box-shadow: none;
            -moz-box-shadow: none;
            -webkit-box-shadow: none;
        }
        .switcher {
            font-size: 0pt !important;
        }
        .switcher label * {
            vertical-align: middle;
            overflow: hidden;
        }
        .switcher input {
            display: none;
        }
        .switcher label input + span {
            position: relative;
            display: inline-block;
            margin-right: 10px;
            width: 100px;
            height: 38.2px;
            background-color: var(--box-background-colour);
            border:1px solid var(--input-border-colour);
            transition: all 0.3s ease-in-out;
        }
        .switcher label input + span small {
            position: absolute;
            display: block;
            width: 50%;
            height: 100%;
            overflow: hidden;
            cursor: pointer;
            background-color: var(--button-background-colour-disabled);
            transition: all .15s ease;
            box-shadow: none;
            font-size: 12px;
            font-weight: 600;
            text-align: center;
            user-select: none;
        }
        .switcher label input:checked + span {
            background-color: var(--box-background-colour);
        }
        .switcher label input:checked + span small {
            background-color: var(--button-background-colour);
            left: 50%;
        }
        .switcher label input:checked + span .switcher-off {
            display: none;
        }
        .switcher label input:checked + span .switcher-on {
            display: block;
        }

        /* Buttons */
        button, .default-item, .button-blank  {
            color: var(--button-text-colour);
            font-family: 'subheading', Helvetica, sans-serif;
            font-size: 44pt;
            line-height: 34pt;
        }
        button, .button-blank, .button {
            padding: 10px 40px;
        }
        .default-item {
            vertical-align: middle;
            padding: 30px 0px 0px 0px;
        }
        .button, button, .button-blank {
            background-color: var(--button-background-colour);
            border: 3px solid var(--button-border-colour);
            cursor: pointer;
            text-decoration: none;
        }
        .button-blank {
            background: none !important;
            border: 0 !important;
        }
        button:hover, .button:hover {
            background-color: var(--button-hover-background-colour);
        }
        .button-blank:hover {
            color: var(--button-hover-background-colour);
        }
        .page-toolbar, #tags {
            margin-bottom: 20px !important;
        }
        #tags {
            width: 100%;
        }
        .page-toolbar {
            display: flex;
        }
        .page-toolbar .round {
            margin-right: 20px;
        }
        .round {
            display: block;
            height: 100px !important;
            width: 100px !important;
            border-radius: 50%;
            text-align: center;
            vertical-align: middle;
            padding: 0 !important;
            font-size: 0pt !important;
            background-color: var(--button-background-colour);
            border: 3px solid var(--button-border-colour);
            cursor: pointer;
        }
        .round img {
            margin-top: 20px;
            width: 60px;
        }
        .mini {
            display: block;
            cursor: pointer;
            width: 40px !important;
            height: 40px !important;
        }
        .mini.icon::before {
            width: 40px !important;
            height: 40px !important;
            left: 0px !important;
            top: 0px !important;
            background-size: 400px 400px;
            
        }
        .mini.icon-edit::before {
            background-position: -160px -40px !important;
        }
        .deleted .round, .deleted .button, .deleted button {
            background-color: var(--box-deleted-background-colour);
        }

        /* Box */
        .box, .table {
            border: 3px solid var(--box-border-colour);
            box-shadow: var(--box-shadow);
            background-color: var(--box-background-colour);
            margin-bottom: 40px;
            border-collapse: collapse;
            min-width: 50%;
        }
        #login.box {
            width: 50%;
        }
        .alert {
            border: 3px solid var(--box-border-colour);
            box-shadow: var(--box-shadow);
            background-color: var(--box-background-colour);
            margin-bottom: 40px;
            font-size: 48pt;
            font-weight: bold;
            font-family: 'heading', Helvetica, sans-serif;
            padding: 20px;
        }
        .row {
            display:flex;
            column-gap: 20px;
        }
        .box-body {
            padding: 40px 40px;
        }
        .box-footer {
            padding: 0 40px 40px 40px;
            display: flex;
            justify-content: flex-end;
        }
        .box-footer a, .box-footer button {
            margin-left: 20px;
        }
        .box-title {
            display: flex;
            flex-direction: row;
        }
        .box-title, .table th, .table td {
            padding: 20px;
            border-bottom: 3px solid var(--box-title-border-colour);
        }
        .box-title, .table th {
            background-color: var(--box-title-background-colour);
            font-size: 48pt;
            font-weight: bold;
            font-family: 'heading', Helvetica, sans-serif;
        }
        .table th {
            font-size: 32pt;
        }
        .table th, .table td {
            text-align: left;
            border-right: 3px solid var(--box-title-border-colour);
        }
        .table tr.deleted {
            color: var(--text-deleted);
            text-decoration: line-through;
        }
        .table tr .blank {
            background-color: var(--box-disabled-background-colour);
        }
        .table tr .total {
            background-color: var(--box-title-background-colour);
            text-align: right;
        }
        .box-title img {
            width: 80px;
            margin-right: 10px;
        }
        .error .box-body, .success .box-body {
            font-family: 'heading', Helvetica, sans-serif;
            font-size: 56pt;
            text-transform: uppercase;
        }
        .error .box-body p, .success .box-body p {
            padding: 0;
            margin: 0;
        }
        .deleted.alert, .deleted .box-title {
            background-color: var(--box-deleted-background-colour);
        }
        .warning.alert {
            background-color: var(--box-warning-background-colour);
        }
        /* Quick menu */
        #quick-menu-button {                
            position: fixed;
            right: 30px;
            top: 30px;
            z-index: 100;
        }
        #quick-menu {
            position: fixed;
            right: 55px;
            top: 140px;
            width: 80px;
            z-index: 101;
        }
        #quick-menu .round, #quick-menu-button .round, .page-toolbar .round {
            display: block;
            height: 100px;
            width: 100px;
            border-radius: 50%;
            text-align: center;
            vertical-align: middle;
            overflow: hidden;
            box-shadow: var(--button-shadow);
        }
        #quick-menu .round, .page-toolbar .round  {
            margin-bottom: 10px;
        }
        #quick-menu img, .page-toolbar img {
            margin-top: 20px;
            width: 60px;
        }
        #quick-menu-button img {
            margin-top: 22px;
            width: 80px;
        }
        
        #message-count, #appointments {
            border-radius: 40px;
            background-color: #fff;
            padding: 15px 20px 10px 20px;
            position: absolute;
            margin-top: -127px;
            margin-left: -208px;
            box-shadow: var(--button-shadow);
            font-weight: bold;
            border: 3px solid var(--text-heading-border-colour);
            font-family: 'subheading', Helvetica, sans-serif;
            font-size: 36pt;
            line-height: 26pt;
        }
        #message-count span, #appointments span {
            content: '';
            position: absolute;
            display: block;
            width: 64px;
            height: 64px;
            margin-left: 123px;
            margin-top: -46px;
            background-image: url('/assets/icons.png');
            background-repeat: no-repeat;
            background-position: -256px -128px;
        }
        #appointments {
            margin-left: -244px;
            margin-top: -34px;
        }
        #appointments span {
            margin-left: 164px;
            margin-top: -61px;
            background-position: -512px -128px;
        }

        /* Calendar */
        #calendar {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(160px, 1fr));
            border-top: 3px solid var(--text-heading-border-colour);
            border-left: 3px solid var(--text-heading-border-colour);
        }
        #calendar-month {
            font-family: 'heading', Helvetica, sans-serif;
            font-size: 56pt;
            line-height: 56pt;
            margin-top: 20px;
            margin-bottom: 20px;
        }
        #calendar-month a, #calendar-month span {
            float: left;
            margin-right: 10px;
        }
        #calendar-month span {
            padding-top: 7px !important;
        }
        #calendar-month div {
            float: left;
            padding-bottom: 10px !important;
        }
        #calendar-month a {
            display: block;
            width: 64px;
            height: 64px;
        }
        #calendar-month a:hover {
            text-decoration: none;
        }
        #calendar-month a:before {
            top: 10px !important;
            left: 0 !important;
        }
        #calendar .calendar-entry, #calendar .calendar-day, #calendar .calendar-blank {
            padding: 10px;
            background-color: #fff;
            border-bottom: 3px solid var(--text-heading-border-colour);
            border-right: 3px solid var(--text-heading-border-colour);
        }
        #calendar .calendar-blank {
            background-color: #dfdfdf;
        }
        .calendar-today {
            color: var(--box-active-background-colour);
            font-weight: bold;
        }
        #calendar .calendar-entry {
            display: flex;
            flex-direction: column;
        }
        .calendar-event {
            padding: 10px;
            background-color: var(--box-active-background-colour);
            margin-top: 5px;
            color: var(--body-text-colour);
            font-weight: normal;
        }
        .calendar-free-slot {
            background-color: #F2845F;
        }

        .calendar-free-slot small span {
            color: #fff;
            font-weight: bold;
        }

        /* Products */
        .product-stock, .product-price {
            padding: 10px;
            border-radius: 15px;
            margin-top: 10px;
            margin-right: 10px;
        }
        .product-stock {
            color: #fff;
            background-color: var(--box-success-background-colour);
        }
        .product-price {
            color: #fff;
            background-color: var(--box-success-background-colour);
        }

        /* Statuses */
        .status {
            padding: 15px 20px;
            border-radius: 20px;
            background-color: var(--box-active-background-colour);
            display: block;
            text-align: center;
        }
        .status-basket {
            background-color: var(--box-warning-background-colour);
        }
        .deleted .status {
            color: var(--text-disabled) !important;
            text-decoration: none !important;
            background-color: var(--box-deleted-background-colour) !important;
        }
                
        /* Text */
        h1, h2, h3, h4, h5, h6 {
            font-family: 'subheading', Helvetica, sans-serif;
            font-size: 56pt;
            margin: 20px 0 50px 0;
        }
        h1 {
            font-size: 78pt;
            line-height: 78pt;
        }
        h2 {
            font-size: 56pt;
            line-height: 56pt;
        }
        .page-title span, .no-results span, .page-sub-title span, #calendar-month div {
            background-color: var(--text-heading-background-colour);
            border: 3px solid var(--text-heading-border-colour);
            margin: 0;
            padding: 10px 40px 0 40px;
            box-shadow: var(--text-heading-shadow);
            background-repeat: no-repeat;
            background-position: 20px 20px;
            background-size: 64px;
        }
        .page-title span.icon {
            padding: 0px 40px 10px 100px;
        }
        .page-sub-title span {
            padding: 20px 40px;
        }
        .required {
            padding-top: 10px;
            color: var(--text-required-colour);
        }

        /* Sizes */
        .wfull {
            width: 100%;
        }

        /* Tiles */
        @media only screen and (min-width: 480px) {
            #tiles {
                -moz-column-count: 2;
                -webkit-column-count: 2;
                column-count: 2;
            }
        }

        @media only screen and (min-width: 768px) {
            #tiles {
                -moz-column-count: 2;
                -webkit-column-count: 2;
                column-count: 2;
            }
        }

        @media only screen and (min-width: 960px) {
            #tiles {
                -moz-column-count: 3;
                -webkit-column-count: 3;
                column-count: 3;
            }
            #pages #tiles {
                -moz-column-count: 2;
                -webkit-column-count: 2;
                column-count: 2;
            }
        }

        #tiles {
            column-gap: 40px;
        }

        .tile {
            display: inline-block;
            break-inside: avoid-column;
            margin: 0 0 40px 0;
            width: 100%;
        }
        .tile .box-body {
            padding: 20px 10px;
        }
        .tile .box-body .thumb {
            overflow: hidden;
        }
        .tile .box-body .box-tags {
            float: left;
            width: 100%;
        }
        .tile .box-body .box-tags, #tags {
            margin-top: 10px;
            margin-bottom: 10px;
        }
        .tile .box-body .box-tags .tag, #tags .tag {
            float: left;
            margin-right: 5px;
            margin-bottom: 5px;
            border-radius: 25px;
            padding: 15px;
            background-color: #fff;
            border: 3px solid var(--box-title-background-colour);
        }
        .tag.selected {
            color: #fff;
            background-color: var(--box-title-background-colour) !important;
        }
        .tile .box-body .thumb img {
            width: 100%;
        }
        /* Icons */
        .icon {
            width: 64px;
            height: 64px;
            position: relative;
        }
        .icon::before {
            content: '';
            position: absolute;
            width: 64px;
            height: 64px;
            left: 20px;
            top: 20px;
            right: 0px;
            bottom: 0px;
            background-image: url('/assets/icons.png?t=" . time () . "');
            background-repeat: no-repeat;
            background-position: 0 0;
        }
        .icon-dumbdog::before {
            width: 80px;
            height: 68px;
            left: 14px;
            top: 16px;
            background-position: -512px -64px;
        }
        .icon-pages::before {
            background-position: -512px 0px;
        }
        .icon-dashboard::before {
            background-position: -384px -64px;
        }
        .icon-settings::before {
            background-position: -384px 0px;
        }
        .icon-logout::before {
            background-position: -576px 0px;
        }
        .icon-users::before {
            background-position: -192px 0px;
        }
        .icon-login::before {
            background-position: 0px -64px;
        }
        .icon-files::before {
            background-position: -128px -64px;
        }
        .icon-templates::before {
            background-position: -320px 0px;
        }
        .icon-back::before {
            background-position: -64px 0px;
        }
        .icon-web::before {
            background-position: -128px 0px;
        }
        .icon-recover::before {
            background-position: -448px 0px;
        }
        .icon-delete::before {
            background-position: -320px -64px;
        }
        .icon-themes::before {
            background-position: -256px 0px;
        }
        .icon-copy::before {
            background-position: -448px -64px;
        }
        .icon-edit::before {
            background-position: -256px -64px;
        }
        .icon-error::before {
            background-position: -192px -64px;
        }
        .icon-events::before {
            background-position: 0px -128px;
        }
        .icon-up::before {
            background-position: -64px -128px;
        }
        .icon-comments::before {
            background-position: -128px -128px;
        }
        .icon-messages::before {
            background-position: -192px -128px;
        }
        .icon-message-read::before {
            background-position: -320px -128px;
        }
        .icon-message-view::before {
            background-position: -384px -128px;
        }
        .icon-appointments::before {
            background-position: -448px -128px;
        }
        .icon-next::before {
            background-position: -576px -128px;
        }
        .icon-prev::before {
            background-position: 0 -192px;
        }
        .icon-products::before {
            background-position: -64px -192px;
        }
        .icon-orders::before {
            background-position: -128px -192px;
        }
        </style>";
    }

    private function tagify()
    {
        return "@charset \"UTF-8\";:root{--tagify-dd-color-primary:rgb(53,149,246);--tagify-dd-bg-color:white;--tagify-dd-item-pad:.3em .5em}.tagify{--tags-disabled-bg:#F1F1F1;--tags-border-color:#DDD;--tags-hover-border-color:#CCC;--tags-focus-border-color:#3595f6;--tag-border-radius:3px;--tag-bg:#E5E5E5;--tag-hover:#D3E2E2;--tag-text-color:black;--tag-text-color--edit:black;--tag-pad:0.3em 0.5em;--tag-inset-shadow-size:1.1em;--tag-invalid-color:#D39494;--tag-invalid-bg:rgba(211, 148, 148, 0.5);--tag-remove-bg:rgba(211, 148, 148, 0.3);--tag-remove-btn-color:black;--tag-remove-btn-bg:none;--tag-remove-btn-bg--hover:#c77777;--input-color:inherit;--tag--min-width:1ch;--tag--max-width:auto;--tag-hide-transition:0.3s;--placeholder-color:rgba(0, 0, 0, 0.4);--placeholder-color-focus:rgba(0, 0, 0, 0.25);--loader-size:.8em;--readonly-striped:1;display:inline-flex;align-items:flex-start;flex-wrap:wrap;border:1px solid var(--tags-border-color);padding:0;line-height:0;cursor:text;outline:0;position:relative;box-sizing:border-box;transition:.1s}@keyframes tags--bump{30%{transform:scale(1.2)}}@keyframes rotateLoader{to{transform:rotate(1turn)}}.tagify:hover:not(.tagify--focus):not(.tagify--invalid){--tags-border-color:var(--tags-hover-border-color)}.tagify[disabled]{background:var(--tags-disabled-bg);filter:saturate(0);opacity:.5;pointer-events:none}.tagify[disabled].tagify--select,.tagify[readonly].tagify--select{pointer-events:none}.tagify[disabled]:not(.tagify--mix):not(.tagify--select),.tagify[readonly]:not(.tagify--mix):not(.tagify--select){cursor:default}.tagify[disabled]:not(.tagify--mix):not(.tagify--select)>.tagify__input,.tagify[readonly]:not(.tagify--mix):not(.tagify--select)>.tagify__input{visibility:hidden;width:0;margin:5px 0}.tagify[disabled]:not(.tagify--mix):not(.tagify--select) .tagify__tag>div,.tagify[readonly]:not(.tagify--mix):not(.tagify--select) .tagify__tag>div{padding:var(--tag-pad)}.tagify[disabled]:not(.tagify--mix):not(.tagify--select) .tagify__tag>div::before,.tagify[readonly]:not(.tagify--mix):not(.tagify--select) .tagify__tag>div::before{animation:readonlyStyles 1s calc(-1s * (var(--readonly-striped) - 1)) paused}@keyframes readonlyStyles{0%{background:linear-gradient(45deg,var(--tag-bg) 25%,transparent 25%,transparent 50%,var(--tag-bg) 50%,var(--tag-bg) 75%,transparent 75%,transparent) 0/5px 5px;box-shadow:none;filter:brightness(.95)}}.tagify[disabled] .tagify__tag__removeBtn,.tagify[readonly] .tagify__tag__removeBtn{display:none}.tagify--loading .tagify__input>br:last-child{display:none}.tagify--loading .tagify__input::before{content:none}.tagify--loading .tagify__input::after{content:\"\";vertical-align:middle;opacity:1;width:.7em;height:.7em;width:var(--loader-size);height:var(--loader-size);min-width:0;border:3px solid;border-color:#eee #bbb #888 transparent;border-radius:50%;animation:rotateLoader .4s infinite linear;content:\"\"!important;margin:-2px 0 -2px .5em}.tagify--loading .tagify__input:empty::after{margin-left:0}.tagify+input,.tagify+textarea{position:absolute!important;left:-9999em!important;transform:scale(0)!important}.tagify__tag{display:inline-flex;align-items:center;margin:5px 0 5px 5px;position:relative;z-index:1;outline:0;line-height:normal;cursor:default;transition:.13s ease-out}.tagify__tag>div{vertical-align:top;box-sizing:border-box;max-width:100%;padding:var(--tag-pad);color:var(--tag-text-color);line-height:inherit;border-radius:var(--tag-border-radius);white-space:nowrap;transition:.13s ease-out}.tagify__tag>div>*{white-space:pre-wrap;overflow:hidden;text-overflow:ellipsis;display:inline-block;vertical-align:top;min-width:var(--tag--min-width);max-width:var(--tag--max-width);transition:.8s ease,.1s color}.tagify__tag>div>[contenteditable]{outline:0;-webkit-user-select:text;user-select:text;cursor:text;margin:-2px;padding:2px;max-width:350px}.tagify__tag>div::before{content:\"\";position:absolute;border-radius:inherit;inset:var(--tag-bg-inset,0);z-index:-1;pointer-events:none;transition:120ms ease;animation:tags--bump .3s ease-out 1;box-shadow:0 0 0 var(--tag-inset-shadow-size) var(--tag-bg) inset}.tagify__tag:focus div::before,.tagify__tag:hover:not([readonly]) div::before{--tag-bg-inset:-2.5px;--tag-bg:var(--tag-hover)}.tagify__tag--loading{pointer-events:none}.tagify__tag--loading .tagify__tag__removeBtn{display:none}.tagify__tag--loading::after{--loader-size:.4em;content:\"\";vertical-align:middle;opacity:1;width:.7em;height:.7em;width:var(--loader-size);height:var(--loader-size);min-width:0;border:3px solid;border-color:#eee #bbb #888 transparent;border-radius:50%;animation:rotateLoader .4s infinite linear;margin:0 .5em 0 -.1em}.tagify__tag--flash div::before{animation:none}.tagify__tag--hide{width:0!important;padding-left:0;padding-right:0;margin-left:0;margin-right:0;opacity:0;transform:scale(0);transition:var(--tag-hide-transition);pointer-events:none}.tagify__tag--hide>div>*{white-space:nowrap}.tagify__tag.tagify--noAnim>div::before{animation:none}.tagify__tag.tagify--notAllowed:not(.tagify__tag--editable) div>span{opacity:.5}.tagify__tag.tagify--notAllowed:not(.tagify__tag--editable) div::before{--tag-bg:var(--tag-invalid-bg);transition:.2s}.tagify__tag[readonly] .tagify__tag__removeBtn{display:none}.tagify__tag[readonly]>div::before{animation:readonlyStyles 1s calc(-1s * (var(--readonly-striped) - 1)) paused}@keyframes readonlyStyles{0%{background:linear-gradient(45deg,var(--tag-bg) 25%,transparent 25%,transparent 50%,var(--tag-bg) 50%,var(--tag-bg) 75%,transparent 75%,transparent) 0/5px 5px;box-shadow:none;filter:brightness(.95)}}.tagify__tag--editable>div{color:var(--tag-text-color--edit)}.tagify__tag--editable>div::before{box-shadow:0 0 0 2px var(--tag-hover) inset!important}.tagify__tag--editable>.tagify__tag__removeBtn{pointer-events:none}.tagify__tag--editable>.tagify__tag__removeBtn::after{opacity:0;transform:translateX(100%) translateX(5px)}.tagify__tag--editable.tagify--invalid>div::before{box-shadow:0 0 0 2px var(--tag-invalid-color) inset!important}.tagify__tag__removeBtn{order:5;display:inline-flex;align-items:center;justify-content:center;border-radius:50px;cursor:pointer;font:14px/1 Arial;background:var(--tag-remove-btn-bg);color:var(--tag-remove-btn-color);width:14px;height:14px;margin-right:4.6666666667px;margin-left:auto;overflow:hidden;transition:.2s ease-out}.tagify__tag__removeBtn::after{content:\"×\";transition:.3s,color 0s}.tagify__tag__removeBtn:hover{color:#fff;background:var(--tag-remove-btn-bg--hover)}.tagify__tag__removeBtn:hover+div>span{opacity:.5}.tagify__tag__removeBtn:hover+div::before{box-shadow:0 0 0 var(--tag-inset-shadow-size) var(--tag-remove-bg,rgba(211,148,148,.3)) inset!important;transition:box-shadow .2s}.tagify:not(.tagify--mix) .tagify__input br{display:none}.tagify:not(.tagify--mix) .tagify__input *{display:inline;white-space:nowrap}.tagify__input{flex-grow:1;display:inline-block;min-width:110px;margin:5px;padding:var(--tag-pad);line-height:normal;position:relative;white-space:pre-wrap;color:var(--input-color);box-sizing:inherit}.tagify__input:empty::before{position:static}.tagify__input:focus{outline:0}.tagify__input:focus::before{transition:.2s ease-out;opacity:0;transform:translatex(6px)}@supports (-ms-ime-align:auto){.tagify__input:focus::before{display:none}}.tagify__input:focus:empty::before{transition:.2s ease-out;opacity:1;transform:none;color:rgba(0,0,0,.25);color:var(--placeholder-color-focus)}@-moz-document url-prefix(){.tagify__input:focus:empty::after{display:none}}.tagify__input::before{content:attr(data-placeholder);height:1em;line-height:1em;margin:auto 0;z-index:1;color:var(--placeholder-color);white-space:nowrap;pointer-events:none;opacity:0;position:absolute}.tagify__input::after{content:attr(data-suggest);display:inline-block;vertical-align:middle;position:absolute;min-width:calc(100% - 1.5em);text-overflow:ellipsis;overflow:hidden;white-space:pre;color:var(--tag-text-color);opacity:.3;pointer-events:none;max-width:100px}.tagify__input .tagify__tag{margin:0 1px}.tagify--mix{display:block}.tagify--mix .tagify__input{padding:5px;margin:0;width:100%;height:100%;line-height:1.5;display:block}.tagify--mix .tagify__input::before{height:auto;display:none;line-height:inherit}.tagify--mix .tagify__input::after{content:none}.tagify--select::after{content:\">\";opacity:.5;position:absolute;top:50%;right:0;bottom:0;font:16px monospace;line-height:8px;height:8px;pointer-events:none;transform:translate(-150%,-50%) scaleX(1.2) rotate(90deg);transition:.2s ease-in-out}.tagify--select[aria-expanded=true]::after{transform:translate(-150%,-50%) rotate(270deg) scaleY(1.2)}.tagify--select .tagify__tag{position:absolute;top:0;right:1.8em;bottom:0}.tagify--select .tagify__tag div{display:none}.tagify--select .tagify__input{width:100%}.tagify--empty .tagify__input::before{transition:.2s ease-out;opacity:1;transform:none;display:inline-block;width:auto}.tagify--mix .tagify--empty .tagify__input::before{display:inline-block}.tagify--focus{--tags-border-color:var(--tags-focus-border-color);transition:0s}.tagify--invalid{--tags-border-color:#D39494}.tagify__dropdown{position:absolute;z-index:9999;transform:translateY(1px);overflow:hidden}.tagify__dropdown[placement=top]{margin-top:0;transform:translateY(-100%)}.tagify__dropdown[placement=top] .tagify__dropdown__wrapper{border-top-width:1.1px;border-bottom-width:0}.tagify__dropdown[position=text]{box-shadow:0 0 0 3px rgba(var(--tagify-dd-color-primary),.1);font-size:.9em}.tagify__dropdown[position=text] .tagify__dropdown__wrapper{border-width:1px}.tagify__dropdown__wrapper{max-height:300px;overflow:auto;overflow-x:hidden;background:var(--tagify-dd-bg-color);border:1px solid;border-color:var(--tagify-dd-color-primary);border-bottom-width:1.5px;border-top-width:0;box-shadow:0 2px 4px -2px rgba(0,0,0,.2);transition:.25s cubic-bezier(0,1,.5,1)}.tagify__dropdown__header:empty{display:none}.tagify__dropdown__footer{display:inline-block;margin-top:.5em;padding:var(--tagify-dd-item-pad);font-size:.7em;font-style:italic;opacity:.5}.tagify__dropdown__footer:empty{display:none}.tagify__dropdown--initial .tagify__dropdown__wrapper{max-height:20px;transform:translateY(-1em)}.tagify__dropdown--initial[placement=top] .tagify__dropdown__wrapper{transform:translateY(2em)}.tagify__dropdown__item{box-sizing:border-box;padding:var(--tagify-dd-item-pad);margin:1px;cursor:pointer;border-radius:2px;position:relative;outline:0;max-height:60px;max-width:100%}.tagify__dropdown__item--active{background:var(--tagify-dd-color-primary);color:#fff}.tagify__dropdown__item:active{filter:brightness(105%)}.tagify__dropdown__item--hidden{padding-top:0;padding-bottom:0;margin:0 1px;pointer-events:none;overflow:hidden;max-height:0;transition:var(--tagify-dd-item--hidden-duration,.3s)!important}.tagify__dropdown__item--hidden>*{transform:translateY(-100%);opacity:0;transition:inherit}";
    }
}