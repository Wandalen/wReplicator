( function _Replicator_test_s_()
{

'use strict';

if( typeof module !== 'undefined' )
{

  const _ = require( '../../../node_modules/Tools' );

  require( '../l4/Replicator.s' );

  _.include( 'wTesting' );
  _.include( 'wStringer' );

}

const _global = _global_;
const _ = _global_.wTools;

// --
// tests
// --

/* qqq : make sure all lookers with field result have such test routine */
function iteratorResult( test )
{

  /* */

  test.case = 'control';

  var src =
  {
    a : 'str',
    b : [ 'str', { c : 13, d : [], e : {} } ],
  }

  var expected =
  {
    a : 'str',
    b : [ 'str', { c : 13, d : [], e : {} } ],
  }

  var got = _.replicate({ src });
  test.identical( got, expected );
  test.identical( src, expected );

  /* */

  test.case = 'iterator.result';

  var src =
  {
    a : 'str',
    b : [ 'str', { c : 13, d : [], e : {} } ],
  }

  var expected =
  {
    a : 'str',
    b : [ 'str', { c : 13, d : [], e : {} } ],
  }

  var it = _.replicate.head( _.replicate, [ { src } ] );
  var got = it.perform();
  test.true( got === it );
  test.identical( it.result, expected );
  test.identical( src, expected );

  /* */

}

//

/* qqq : split the test routine */
function basic( test )
{

  /* qqq : use collecting of it principle in all relevant test routines */
  /* qqq : add subroutine clean() and extend test routine */
  let ups = [];
  let downs = [];
  let routine = () => {};

  var src =
  {
    a : 1,
    b : 's',
    c : [ 1, 3 ],
    d : [ 1, { date : new Date( Date.UTC( 1993, 12, 12 ) ) } ],
    e : routine,
    f : new BufferRaw( 13 ),
    g : new F32x([ 1, 2, 3 ]),
    h : false,
    i : true,
    j : { a : 1, b : 2 },
  }

  let clone =
  {
    a : 1,
    b : 's',
    c : [ 1, 3 ],
    d : [ 1, { date : new Date( Date.UTC( 1993, 12, 12 ) ) } ],
    e : routine,
    f : new BufferRaw( 13 ),
    g : new F32x([ 1, 2, 3 ]),
    h : false,
    i : true,
    j : { a : 1, b : 2 },
  }

  /* */

  test.case = 'basic';

  var got = _.replicate({ src });
  test.true( got !== src );
  test.identical( got, clone );
  test.identical( src, clone );
  test.true( got !== src );
  test.true( got.a === src.a );
  test.true( got.b === src.b );
  test.true( got.c !== src.c );
  test.true( got.d !== src.d );
  test.true( got.e === src.e );
  test.true( got.f === src.f );
  test.true( got.g === src.g );
  test.true( got.h === src.h );
  test.true( got.i === src.i );
  test.true( got.j !== src.j );

  /* */

  test.case = 'additional handlers';

  var got = _.replicate
  ({
    src,
    onUp : handleUp,
    onDown : handleDown,
  });
  test.true( got !== src );
  test.identical( got, clone );
  test.identical( src, clone );
  test.true( got.a === src.a );
  test.true( got.b === src.b );
  test.true( got.c !== src.c );
  test.true( got.d !== src.d );
  test.true( got.e === src.e );
  test.true( got.f === src.f );
  test.true( got.g === src.g );
  test.true( got.h === src.h );
  test.true( got.i === src.i );
  test.true( got.j !== src.j );

  let expectedUpPaths = [ '/', '/a', '/b', '/c', '/c/#0', '/c/#1', '/d', '/d/#0', '/d/#1', '/d/#1/date', '/e', '/f', '/g', '/h', '/i', '/j', '/j/a', '/j/b' ];
  let expectedUpIndices = [ null, 0, 1, 2, 0, 1, 3, 0, 1, 0, 4, 5, 6, 7, 8, 9, 0, 1 ];
  let expectedDownPaths = [ '/a', '/b', '/c/#0', '/c/#1', '/c', '/d/#0', '/d/#1/date', '/d/#1', '/d', '/e', '/f', '/g', '/h', '/i', '/j/a', '/j/b', '/j', '/' ];
  let expectedDownIndices = [ 0, 1, 0, 1, 2, 0, 0, 1, 3, 4, 5, 6, 7, 8, 0, 1, 9, null ];

  test.description = 'expectedUpPaths';
  test.identical( ups.map( ( it ) => it.path ), expectedUpPaths );
  test.description = 'expectedUpIndices';
  test.identical( ups.map( ( it ) => it.index ), expectedUpIndices );
  test.description = 'expectedUpPaths';
  test.identical( downs.map( ( it ) => it.path ), expectedDownPaths );
  test.description = 'expectedDownIndices';
  test.identical( downs.map( ( it ) => it.index ), expectedDownIndices );

  /* */

  test.case = 'single src';
  var src = [ 1, 3 ];
  var got = _.replicate({ src })
  test.identical( got, src );
  test.true( got !== src );

  /* */

  function handleUp()
  {
    let it = this;
    ups.push( _.props.extend( null, it ) );
  }

  function handleDown()
  {
    let it = this;
    downs.push( _.props.extend( null, it ) );
  }

}

//

function replicateCallingCallback( test )
{

  /* */

  test.case = 'l1';
  var src = [ 'a', 13, 'b' ];
  var exp = [ 'aa', 13, 'bb' ];
  var got = _.replicate( null, src, ( e, k, it ) =>
  {
    if( _.str.is( it.src ) )
    {
      it.dst = it.src + it.src;
      it.dstMaking = false;
    }
  });
  test.identical( got, exp );
  test.true( got !== exp );

  /* */

}

//

function replicateArray( test )
{

  /* */

  test.case = 'l1';
  var src = [ 'a', 'b' ];
  var exp = [ 'a', 'b' ];
  var got = _.replicate( null, src );
  test.identical( got, exp );
  test.true( got !== exp );

  /* */

  test.case = 'l2';
  var src = [ [ 'a', 'b' ], [ 'c' ], 'd' ];
  var exp = [ [ 'a', 'b' ], [ 'c' ], 'd' ];
  var got = _.replicate( null, src );
  test.identical( got, exp );
  test.true( got !== exp );
  test.true( got[ 0 ] !== exp[ 0 ] );
  test.true( got[ 1 ] !== exp[ 1 ] );

  /* */

}

//

function replicateSet( test )
{

  /* */

  test.case = 'l1';
  var src = new Set([ 'a', 'b' ]);
  var exp = new Set([ 'a', 'b' ]);
  var got = _.replicate( null, src );
  test.identical( got, exp );
  test.true( got !== exp );

  /* */

  test.case = 'l2';
  var src = new Set([ new Set([ 'a', 'b' ]), new Set([ 'c' ]), 'd' ]);
  var exp = new Set([ new Set([ 'a', 'b' ]), new Set([ 'c' ]), 'd' ]);
  var got = _.replicate( null, src );
  test.identical( got, exp );
  test.true( got !== exp );
  test.true( [ ... got ][ 0 ] !== [ ... exp ][ 0 ] );
  test.true( [ ... got ][ 1 ] !== [ ... exp ][ 1 ] );

  /* */

}

//

function replicateMap( test )
{

  /* */

  test.case = 'l1';
  var src = { 'a' : 'av', 'b' : 'bv' };
  var exp = { 'a' : 'av', 'b' : 'bv' };
  var got = _.replicate( null, src );
  test.identical( got, exp );
  test.true( got !== exp );

  /* */

  test.case = 'l2';
  var src = { 'ab' : { 'a' : 'av', 'b' : 'bv' }, 'c' : { 'c' : 'cv' }, 'd' : 'dv' };
  var exp = { 'ab' : { 'a' : 'av', 'b' : 'bv' }, 'c' : { 'c' : 'cv' }, 'd' : 'dv' };
  var got = _.replicate( null, src );
  test.identical( got, exp );
  test.true( got !== exp );
  test.true( got[ 'ab' ] !== exp[ 'ab' ] );
  test.true( got[ 'c' ] !== exp[ 'c' ] );

  /* */

}

//

function replicateHashMap( test )
{

  /* */

  test.case = 'l1';
  var src = new HashMap([ [ 'a', 'av' ], [ 'b', 'bv' ] ]);
  var exp = new HashMap([ [ 'a', 'av' ], [ 'b', 'bv' ] ]);
  var got = _.replicate( null, src );
  test.identical( got, exp );
  test.true( got !== exp );

  /* */

  test.case = 'l2';
  var src = new HashMap([ [ 'ab', new HashMap([ [ 'a', 'av' ], [ 'b', 'bv' ] ]) ], [ 'c', new HashMap([ [ 'c', 'cv' ] ]) ], [ 'd', 'dv' ] ]);
  var exp = new HashMap([ [ 'ab', new HashMap([ [ 'a', 'av' ], [ 'b', 'bv' ] ]) ], [ 'c', new HashMap([ [ 'c', 'cv' ] ]) ], [ 'd', 'dv' ] ]);
  var got = _.replicate( null, src );
  test.identical( got, exp );
  test.true( got !== exp );
  test.true( got.get( 'ab' ) !== exp.get( 'ab' ) );
  test.true( got.get( 'c' ) !== exp.get( 'c' ) );

  /* */

}

//

function replaceOfSrc( test )
{

  var structure1 =
  {
    a : 1,
    b : '!replace!',
    c : [ 1, 2 ],
    d : [ 1, { date : new Date( Date.UTC( 1993, 12, 12 ) ) } ],
    e : function(){},
    f : new BufferRaw( 13 ),
    g : new F32x([ 1, 2, 3 ]),
    h : false,
    i : true,
    j : { a : 1, b : 2 },
  }

  let expectedUpPaths = [ '/', '/a', '/b', '/b/#0', '/b/#1', '/b/#2', '/b/#3', '/c', '/d', '/e', '/f', '/g', '/h', '/i', '/j' ];
  let expectedUpIndices = [ null, 0, 1, 0, 1, 2, 3, 2, 3, 4, 5, 6, 7, 8, 9 ];
  let expectedDownPaths = [ '/a', '/b/#0', '/b/#1', '/b/#2', '/b/#3', '/b', '/c', '/d', '/e', '/f', '/g', '/h', '/i', '/j', '/' ];
  let expectedDownIndices = [ 0, 0, 1, 2, 3, 1, 2, 3, 4, 5, 6, 7, 8, 9, null ];

  let handleUpPaths = [];
  let handleUpIndices = [];
  let handleDownPaths = [];
  let handleDownIndices = [];

  let replacedForString = [ 'string', 'replaced', 'by', 'this' ];

  /* */

  test.case = '';

  var expected =
  {
    a : 'number replaced by this',
    b : [ 'string', 'replaced', 'by', 'this' ],
    c : 'array replaced by this',
    d : 'array replaced by this',
    e : structure1.e,
    f : new BufferRaw( 13 ),
    g : new F32x([ 1, 2, 3 ]),
    h : false,
    i : true,
    j : 'map replaced by this',
  }

  var got = _.replicate
  ({
    src : structure1,
    onUp : handleUp,
    onDown : handleDown,
  });
  test.identical( got, expected );

  test.case = 'expectedUpPaths';
  test.identical( handleUpPaths, expectedUpPaths );
  test.case = 'expectedUpIndices';
  test.identical( handleUpIndices, expectedUpIndices );
  test.case = 'expectedUpPaths';
  test.identical( handleDownPaths, expectedDownPaths );
  test.case = 'expectedDownIndices';
  test.identical( handleDownIndices, expectedDownIndices );

  /* */

  function handleUp()
  {
    let it = this;

    if( it.src === '!replace!' )
    {
      it.src = replacedForString;
      it.iterable = null;
      it.srcChanged();
    }
    else if( _.numberIs( it.src ) )
    {
      it.src = 'number replaced by this';
      it.iterable = null;
      it.srcChanged();
    }
    else if( _.arrayIs( it.src ) )
    {
      it.src = 'array replaced by this';
      it.iterable = null;
      it.srcChanged();
    }
    else if( _.object.isBasic( it.src ) && _.props.keys( it.src ).length === 2 )
    {
      it.src = 'map replaced by this';
      it.iterable = null;
      it.srcChanged();
    }

    handleUpPaths.push( it.path );
    handleUpIndices.push( it.index );
  }

  function handleDown()
  {
    let it = this;
    handleDownPaths.push( it.path );
    handleDownIndices.push( it.index );
  }

}

//

function exportStructure( test )
{

  Obj1.prototype.exportStructure = exportStructure;
  Obj2.prototype.exportStructure = exportStructure;

  exportStructure.defaults =
  {
    src : null,
    dst : null,
  }

  let obj1 = new Obj1({ a : '1', b : '2' });
  let obj2 = new Obj1({ c : '3', d : obj1 });

  /* */

  test.case = 'obj1.exportStructure';
  var exp =
  {
    'a' : '1',
    'b' : '2',
    exportStructure,
  }
  var got = obj1.exportStructure();
  test.identical( got, exp );
  test.true( got !== obj1 )

  /* */

  test.case = 'obj2.exportStructure';
  var exp =
  {
    'c' : '3',
    'd' :
    {
      'a' : '1',
      'b' : '2',
      exportStructure,
    },
    exportStructure,
  }
  var got = obj2.exportStructure();
  test.identical( got, exp );
  test.true( got !== obj2 )

  /* */

  function Obj1( o )
  {
    return _.props.extend( this, o );
  }
  function Obj2( o )
  {
    return _.props.extend( this, o );
  }

  function exportStructure( o )
  {
    let resource = this;

    o = _.routine.options_( exportStructure, arguments );

    if( o.src === null )
    o.src = resource;

    let dst = Object.create( null );
    if( o.dst === null )
    o.dst = dst;

    let o2 =
    {
      src : o.src,
      dst : o.dst,
      srcChanged,
      ascend,
    }

    o.dst = _.replicate( o2 );

    test.true( o2.dst === dst );
    test.true( o.dst === dst );

    return o.dst;

    function srcChanged()
    {
      let it = this;
      it.Seeker.srcChanged.call( it );
      if( !it.iterable )
      if( _.instanceIs( it.src ) )
      {
        if( it.src === resource )
        {
          it.src = _.props.extend( null, it.src );
          it.iterable = _.replicator.Seeker.ContainerType.aux;
        }
      }
    }

    function ascend()
    {
      let it = this;
      if( !it.iterable && _.instanceIs( it.src ) )
      {
        it.dst = _.routineCallButOnly( it.src, 'exportStructure', o, [ 'src', 'dst' ] );
        it.dstMaking = false;
      }
      else
      {
        it.Seeker.ascend.call( it );
      }
    }

  }

}

//

function firstIterationDstMaking( test )
{

  /* */

  test.case = 'basic';

  var src = [ 1, 2, 3 ];
  var dst = [];
  var opts =
  {
    src,
    dst,
  }
  var got = _.replicate( opts );

  test.true( opts.dst === dst );
  test.true( got === dst );

  /* */

}

firstIterationDstMaking.description =
`
- dstMaking of the first iteration prototype should be set to false if dst is specified
`

//

function iteratorContinue( test )
{
  let ups = [];
  let downs = [];
  let src =
  {
    a : 1,
    b : 's',
  }
  let clone =
  {
    a : 1,
    b : 's',
  }

  /* */

  test.case = 'basic';
  var got = _.replicate({ src, onUp : handleUp, onDown : handleDown });
  test.true( got !== src );
  test.identical( got, undefined );
  test.identical( src, clone );

  /* */

  function handleUp()
  {
    let it = this;
    ups.push( _.props.extend( null, it ) );
    it.iterator.continue = false;
    it.dstMaking = false;
  }

  function handleDown()
  {
    let it = this;
    downs.push( _.props.extend( null, it ) );
  }

}

// --
// declare
// --

const Proto =
{

  name : 'Tools.l3.Replicate',
  silencing : 1,
  enabled : 1,

  context :
  {
  },

  tests :
  {

    iteratorResult,
    basic,
    replicateCallingCallback,
    replicateArray,
    replicateSet,
    replicateMap,
    replicateHashMap,
    replaceOfSrc,
    exportStructure,
    firstIterationDstMaking,
    iteratorContinue,

  }

}

const Self = wTestSuite( Proto );
if( typeof module !== 'undefined' && !module.parent )
wTester.test( Self.name );

})();
