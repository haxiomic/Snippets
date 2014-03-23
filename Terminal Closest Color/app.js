$(function(){
    var diff = require('color-diff');

    var userElements = [];
    var userColors = [];
    var stdElements = [];
    var stdColors = [];
    var bestMatches = [];
    var allP = $('p[class^=p]').each(function(){
        var r = /(\d\d\d)\s=+/i.exec($(this).text());
        if(!r)return;//fail!
        if(typeof r[1] == 'undefined' || isNaN(parseFloat(r[1])))return;//fail!

        var code = parseInt(r[1]);
        if(code<16){
            userColors[code] = getRGB($(this));
            userElements[code] = $(this).clone();
        }else{
            stdColors[code] = getRGB($(this));
            stdElements[code] = $(this).clone(); 
        }
    });

    allP.each(function(){
        $(this).remove();
    })

    $(userColors).each(function(code){
        diff.closest(this,stdColors);
        var c = diff.closest(this,stdColors);
        var ri = -1;
        for (var i = stdColors.length - 1; i >= 0; i--) {
            var e = stdColors[i];

            if((e.R == c.R) && (e.G == c.G) && (e.B == c.B)){
                ri = i;
                break;
            }
        };
        bestMatches[code] = ri;
        $('body').append(userElements[code].clone());
        $('body').append(stdElements[ri].clone());
        $('body').append('<br>');
    })

    var tput = [
        'BLACK=$(tput setaf '+bestMatches[0]+')',
        'RED=$(tput setaf '+bestMatches[1]+')',
        'GREEN=$(tput setaf '+bestMatches[2]+')',
        'YELLOW=$(tput setaf '+bestMatches[3]+')',
        'BLUE=$(tput setaf '+bestMatches[4]+')',
        'MAGENTA=$(tput setaf '+bestMatches[5]+')',
        'CYAN=$(tput setaf '+bestMatches[6]+')',
        'WHITE=$(tput setaf '+bestMatches[7]+')',
        'BRIGHT_BLACK=$(tput setaf '+bestMatches[8]+')',
        'BRIGHT_RED=$(tput setaf '+bestMatches[9]+')',
        'BRIGHT_GREEN=$(tput setaf '+bestMatches[10]+')',
        'BRIGHT_YELLOW=$(tput setaf '+bestMatches[11]+')',
        'BRIGHT_BLUE=$(tput setaf '+bestMatches[12]+')',
        'BRIGHT_MAGENTA=$(tput setaf '+bestMatches[13]+')',
        'BRIGHT_CYAN=$(tput setaf '+bestMatches[14]+')',
        'BRIGHT_WHITE=$(tput setaf '+bestMatches[15]+')'
    ];
    var ascii = [
        'BLACK=\'\\033[38;5;'+bestMatches[0]+'m\'',
        'RED=\'\\033[38;5;'+bestMatches[1]+'m\'',
        'GREEN=\'\\033[38;5;'+bestMatches[2]+'m\'',
        'YELLOW=\'\\033[38;5;'+bestMatches[3]+'m\'',
        'BLUE=\'\\033[38;5;'+bestMatches[4]+'m\'',
        'MAGENTA=\'\\033[38;5;'+bestMatches[5]+'m\'',
        'CYAN=\'\\033[38;5;'+bestMatches[6]+'m\'',
        'WHITE=\'\\033[38;5;'+bestMatches[7]+'m\'',
        'BRIGHT_BLACK=\'\\033[38;5;'+bestMatches[8]+'m\'',
        'BRIGHT_RED=\'\\033[38;5;'+bestMatches[9]+'m\'',
        'BRIGHT_GREEN=\'\\033[38;5;'+bestMatches[10]+'m\'',
        'BRIGHT_YELLOW=\'\\033[38;5;'+bestMatches[11]+'m\'',
        'BRIGHT_BLUE=\'\\033[38;5;'+bestMatches[12]+'m\'',
        'BRIGHT_MAGENTA=\'\\033[38;5;'+bestMatches[13]+'m\'',
        'BRIGHT_CYAN=\'\\033[38;5;'+bestMatches[14]+'m\'',
        'BRIGHT_WHITE=\'\\033[38;5;'+bestMatches[15]+'m\'',
    ];

    console.log(tput.join('\n'));
    console.log(ascii.join('\n'));
})

function getRGB(t){
    var colorStr = t.css('color');
    var r = /\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*\)/i.exec(colorStr);
    return {R:r[1], G:r[2], B:r[3]};
}