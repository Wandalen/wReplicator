( function _Replicator_test_s_()
{

'use strict';

if( typeof module !== 'undefined' )
{

  let _ = require( '../../../wtools/Tools.s' );

  require( '../l4/Replicator.s' );

  _.include( 'wTesting' );
  _.include( 'wStringer' );

}

let _global = _global_;
let _ = _global_.wTools;

// --
// tests
// --

function trivial( test )
{

  var structure1 =
  {
    a : 1,
    b : 's',
    c : [ 1, 3 ],
    d : [ 1, { date : new Date() } ],
    e : function(){},
    f : new BufferRaw( 13 ),
    g : new F32x([ 1, 2, 3 ]),
    h : false,
    i : true,
    j : { a : 1, b : 2 },
  }

  let expectedUpPaths = [ '/', '/a', '/b', '/c', '/c/0', '/c/1', '/d', '/d/0', '/d/1', '/d/1/date', '/e', '/f', '/g', '/h', '/i', '/j', '/j/a', '/j/b' ];
  let expectedUpIndices = [ null, 0, 1, 2, 0, 1, 3, 0, 1, 0, 4, 5, 6, 7, 8, 9, 0, 1 ];
  let expectedDownPaths = [ '/a', '/b', '/c/0', '/c/1', '/c', '/d/0', '/d/1/date', '/d/1', '/d', '/e', '/f', '/g', '/h', '/i', '/j/a', '/j/b', '/j', '/' ];
  let expectedDownIndices = [ 0, 1, 0, 1, 2, 0, 0, 1, 3, 4, 5, 6, 7, 8, 0, 1, 9, null ];

  let handleUpPaths = [];
  let handleUpIndices = [];
  let handleDownPaths = [];
  let handleDownIndices = [];

  function handleUp()
  {
    let it = this;
    handleUpPaths.push( it.path );
    handleUpIndices.push( it.index );
  }

  function handleDown()
  {
    let it = this;
    handleDownPaths.push( it.path );
    handleDownIndices.push( it.index );
  }

  /* */

  test.case = 'trivial';

  var got = _.replicate({ src : structure1 });
  test.identical( got, structure1 );
  test.true( got !== structure1 );
  test.true( got.a === structure1.a );
  test.true( got.b === structure1.b );
  test.true( got.c !== structure1.c );
  test.true( got.d !== structure1.d );
  test.true( got.e === structure1.e );
  test.true( got.f === structure1.f );
  test.true( got.g === structure1.g );
  test.true( got.h === structure1.h );
  test.true( got.i === structure1.i );
  test.true( got.j !== structure1.j );

  /* */

  test.case = 'additional handlers';

  var got = _.replicate
  ({
    src : structure1,
    onUp : handleUp,
    onDown : handleDown,
  });
  test.identical( got, structure1 );
  test.true( got !== structure1 );
  test.true( got.a === structure1.a );
  test.true( got.b === structure1.b );
  test.true( got.c !== structure1.c );
  test.true( got.d !== structure1.d );
  test.true( got.e === structure1.e );
  test.true( got.f === structure1.f );
  test.true( got.g === structure1.g );
  test.true( got.h === structure1.h );
  test.true( got.i === structure1.i );
  test.true( got.j !== structure1.j );

  test.case = 'expectedUpPaths';
  test.identical( handleUpPaths, expectedUpPaths );
  test.case = 'expectedUpIndices';
  test.identical( handleUpIndices, expectedUpIndices );
  test.case = 'expectedUpPaths';
  test.identical( handleDownPaths, expectedDownPaths );
  test.case = 'expectedDownIndices';
  test.identical( handleDownIndices, expectedDownIndices );

}

//

/* xxx : write similar tests for other lookers */
function replicateIteratorResult( test )
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
  var got = it.start();
  test.true( got === it );
  test.identical( it.result, expected );
  test.identical( src, expected );

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
    d : [ 1, { date : new Date() } ],
    e : function(){},
    f : new BufferRaw( 13 ),
    g : new F32x([ 1, 2, 3 ]),
    h : false,
    i : true,
    j : { a : 1, b : 2 },
  }

  let expectedUpPaths = [ '/', '/a', '/b', '/b/0', '/b/1', '/b/2', '/b/3', '/c', '/d', '/e', '/f', '/g', '/h', '/i', '/j' ];
  let expectedUpIndices = [ null, 0, 1, 0, 1, 2, 3, 2, 3, 4, 5, 6, 7, 8, 9 ];
  let expectedDownPaths = [ '/a', '/b/0', '/b/1', '/b/2', '/b/3', '/b', '/c', '/d', '/e', '/f', '/g', '/h', '/i', '/j', '/' ];
  let expectedDownIndices = [ 0, 0, 1, 2, 3, 1, 2, 3, 4, 5, 6, 7, 8, 9, null ];

  let handleUpPaths = [];
  let handleUpIndices = [];
  let handleDownPaths = [];
  let handleDownIndices = [];

  let replacedForString = [ 'string', 'replaced', 'by', 'this' ];

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
    else if( _.objectIs( it.src ) && _.mapKeys( it.src ).length === 2 )
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
    return _.mapExtend( this, o );
  }
  function Obj2( o )
  {
    return _.mapExtend( this, o );
  }

  function exportStructure( o )
  {
    let resource = this;

    o = _.routineOptions( exportStructure, arguments );

    if( o.src === null )
    o.src = resource;

    if( o.dst === null )
    o.dst = Object.create( null );

    o.dst = _.replicate
    ({
      src : o.src,
      dst : o.dst,
      onSrcChanged,
      onAscend,
    });

    return o.dst;

    function onSrcChanged()
    {
      let it = this;

      if( !it.iterable )
      if( _.instanceIs( it.src ) )
      {
        if( it.src === resource )
        {
          it.srcEffective = _.mapExtend( null, it.src );
          it.iterable = _.looker.containerNameToIdMap.aux;
        }
      }

    }

    function onAscend()
    {
      let it = this;

      if( !it.iterable && _.instanceIs( it.src ) )
      {
        it.dst = _.routineCallButOnly( it.src, 'exportStructure', o, [ 'src', 'dst' ] );
      }
      else
      {
        _.Looker.Iterator.onAscend.call( this );
      }

    }

  }

}

// --
// declare
// --

let Self =
{

  name : 'Tools.l3.Replicate',
  silencing : 1,
  enabled : 1,

  context :
  {
  },

  tests :
  {

    trivial,
    replicateIteratorResult,
    replaceOfSrc,
    exportStructure,

  }

}

Self = wTestSuite( Self );
if( typeof module !== 'undefined' && !module.parent )
wTester.test( Self.name );

})();
