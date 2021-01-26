
let _ = require( 'wreplicator' );

/**/

let src = { a : [ 1, 2, 3 ], b : { b1 : 'text', b2 : 13 }, c : new Date }
let got = _.replicate({ src });

console.log( got );

/*
{ a: [ 1, 2, 3 ],
  b: { b1: 'text', b2: 13 },
  c: 2019-02-21T07:44:11.718Z }
*/
