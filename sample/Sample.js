
let _ = require( '..' );

/**/

let src = { a : [ 1, 2, 3 ], b : { b1 : 'text', b2 : 13 }, c : new Date }
let got = _.replicate({ src : src });

console.log( got );
