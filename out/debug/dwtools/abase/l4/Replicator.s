( function _Replicator_s_() {

'use strict';

/**
 * Collection of routines to replicate a complex data structure. It traverse input data structure deeply producing a copy of it.Collection of routines to replicate a complex data structure. It traverses input data structure deeply producing a copy of it.
  @module Tools/base/Replicator
*/

/**
 * @file l4/Replicator.s.
 */

if( typeof module !== 'undefined' )
{

  let _ = require( '../../Tools.s' );

  _.include( 'wLooker' );
  _.include( 'wPathFundamentals' );

}

let _global = _global_;
let Self = _global_.wTools;
let _ = _global_.wTools;

let _ArraySlice = Array.prototype.slice;
let _FunctionBind = Function.prototype.bind;
let _ObjectToString = Object.prototype.toString;
let _ObjectHasOwnProperty = Object.hasOwnProperty;

_.assert( !!_realGlobal_ );

// --
// routines
// --

function replicate_pre( routine, args )
{

  let o = args[ 0 ];
  if( args.length === 2 )
  {
    if( _.lookIterationIs( args[ 0 ] ) )
    o = { it : args[ 0 ], dst : args[ 1 ] }
    else
    o = { src : args[ 0 ], dst : args[ 1 ] }
  }

  _.routineOptionsPreservingUndefines( routine, o );
  _.assert( arguments.length === 2 );
  _.assert( args.length === 1 || args.length === 2 );
  _.assert( o.onUp === null || _.routineIs( o.onUp ) );
  _.assert( o.onDown === null || _.routineIs( o.onDown ) );

  o.prevContext = null;
  if( o.root === null )
  o.root = o.src;

  if( o.it )
  {
    debugger;
    _.assert( o.src === null );
    _.assert( _.lookIterationIs( o.it ) );
    _.assert( _.objectIs( o.it.context ) );
    o.src = o.it.src;
    o.prevContext = o.it.context;
  }

  let o2 = optionsFor( o );
  let it = _.look.pre( _.look, [ o2 ] );

  _.assert( o.it === it || o.it === null );
  _.assert( it.context === o.prevContext || it.context === o );
  it.iterator.context = o;
  _.assert( it.context === o );

  return it;

  /* */

  function optionsFor( o )
  {

    let o2 = Object.create( null );
    o2.src = o.src;
    o2.context = o;
    o2.onUp = up;
    o2.onDown = down;
    o2.Looker = Looker;
    o2.trackingVisits = o.trackingVisits;
    o2.it = o.it;
    o2.iterationCurrent = o.iterationCurrent;
    o2.iteratorExtension = o.iteratorExtension;
    o2.recursive = o.recursive;

    _.assert( arguments.length === 1 );

    return o2;
  }

  /* */

  function up()
  {
    let it = this;
    let c = it.context;

    _.assert( it.iterable !== null && it.iterable !== undefined );
    _.assert( it.dstSet === null );

    if( c.onUp )
    c.onUp.call( it );

    dstMethods.call( it );

    if( it.dstSetting )
    it.dstSet();

  }

  /* */

  function down()
  {
    let it = this;
    let c = it.context;

    if( c.onDown )
    c.onDown.call( it );

    _.assert( it.iterable !== null && it.iterable !== undefined );

    if( it.down && it.dstWritingDown )
    {
      _.assert( _.routineIs( it.down.dstWriteDown ) );
      it.down.dstWriteDown( it );
    }

  }

  /* - */

  function dstMethods()
  {
    let it = this;
    let c = it.context;

    // _.assert( it.dst === null );
    _.assert( it.iterable !== null && it.iterable !== undefined );

    it.dstSet = dstSet;

    if( !it.iterable )
    {
      it.dstWriteDown = function dstWriteDown( eit )
      {
        _.assert( 0, 'Cant write into terminal' );
        this.dst = eit.dst;
      }
    }
    else if( it.iterable === 'array-like' )
    {
      it.dstWriteDown = function( eit )
      {
        if( eit.dst !== undefined )
        this.dst.push( eit.dst );
      }
    }
    else if( it.iterable === 'map-like' )
    {
      it.dstWriteDown = function( eit )
      {
        if( eit.dst === undefined )
        delete this.dst[ eit.key ];
        else
        this.dst[ eit.key ] = eit.dst;
      }
    }

  }

  /* - */

  function dstSet()
  {
    let it = this;
    let c = it.context;

    _.assert( it.dst === null );
    _.assert( it.iterable !== null && it.iterable !== undefined );

    if( !it.iterable )
    {
      it.dst = it.src;
    }
    else if( it.iterable === 'array-like' )
    {
      it.dst = [];
    }
    else if( it.iterable === 'map-like' )
    {
      it.dst = Object.create( null );
    }

  }

}

//

function replicateIt_body( it )
{
  _.assert( arguments.length === 1, 'Expects single argument' );
  _.assert( _.lookerIs( it.Looker ) );
  _.assert( it.looker === undefined );
  it.context.iteration = _.look.body( it );
  return it;
}

replicateIt_body.defaults =
{

  it : null,
  root : null,
  src : null,
  dst :  null,

  trackingVisits : 1,
  iterationCurrent : null,
  iteratorExtension : null,
  recursive : Infinity,

  onUp : null,
  onDown : null,

}

//

let replicateIt = _.routineFromPreAndBody( replicate_pre, replicateIt_body );

//

function replicate_body( it )
{
  let it2 = _.replicateIt.body( it );
  _.assert( it2 === it )
  _.assert( arguments.length === 1, 'Expects single argument' );

  if( it.error )
  throw it.error;

  return it.dst;
}

_.routineExtend( replicate_body, replicateIt );

//

let replicate = _.routineFromPreAndBody( replicate_pre, replicate_body );

// --
// looker
// --

let Looker = _.mapExtend( null, _.look.defaults.Looker );
Looker.Looker = Looker;

Looker.Iteration = _.mapExtend( null, Looker.Iteration );
Looker.Iteration.dst = null;
Looker.Iteration.dstSet = null;
Looker.Iteration.dstSetting = true;
Looker.Iteration.dstWriteDown = null;
Looker.Iteration.dstWritingDown = true;

// --
// declare
// --

let Supplement =
{

  replicateIt,
  replicate,

}

_.mapSupplement( Self, Supplement );

// --
// export
// --

// if( typeof module !== 'undefined' )
// if( _global_.WTOOLS_PRIVATE )
// { /* delete require.cache[ module.id ]; */ }

if( typeof module !== 'undefined' && module !== null )
module[ 'exports' ] = Self;

})();
