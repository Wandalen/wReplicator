( function _Replicator_s_() {

'use strict';

/**
 * Collection of routines to replicate a complex data structure. It traverse input data structure deeply producing a copy of it.Collection of routines to replicate a complex data structure. It traverses input data structure deeply producing a copy of it.
  @module Tools/base/Replicator
*/

/**
 * @file l4/Replicator.s.
 */

/**
 * Collection of routines to replicate a complex data structure.
  @namespace Tools( module::Replicator )
  @memberof module:Tools/base/Replicator
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

  o.prevReplicateOptions = null;
  if( o.root === null )
  o.root = o.src;

  if( o.it )
  {
    debugger;
    _.assert( o.src === null );
    _.assert( _.lookIterationIs( o.it ) );
    _.assert( _.objectIs( o.it.replicateOptions ) );
    o.src = o.it.src;
    o.prevReplicateOptions = o.it.replicateOptions;
  }

  let o2 = optionsFor( o );
  let it = _.look.pre( _.look, [ o2 ] );

  _.assert( o.it === it || o.it === null );
  _.assert( it.replicateOptions === o.prevReplicateOptions || it.replicateOptions === o );
  it.iterator.replicateOptions = o;
  _.assert( it.replicateOptions === o );

  return it;

  /* */

  function optionsFor( o )
  {

    let o2 = Object.create( null );
    o2.src = o.src;
    // o2.context = o;
    o2.onUp = up;
    o2.onDown = down;
    o2.Looker = Looker;
    o2.trackingVisits = o.trackingVisits;
    o2.it = o.it;
    o2.recursive = o.recursive;

    o2.iteratorExtension = o.iteratorExtension;
    o2.iterationExtension = o.iterationExtension;
    o2.iterationPreserve = o.iterationPreserve;

    o2.iteratorExtension = _.mapExtend( null, o2.iteratorExtension || {} );
    _.assert( o2.iteratorExtension.replicateOptions === undefined );
    _.assert( arguments.length === 1 );
    o2.iteratorExtension.replicateOptions = o;

    return o2;
  }

  /* */

  function up()
  {
    let it = this;
    let c = it.replicateOptions;

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
    let c = it.replicateOptions;

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
    let c = it.replicateOptions;

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
    let c = it.replicateOptions;

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
  it.replicateOptions.iteration = _.look.body( it );
  return it;
}

replicateIt_body.defaults =
{

  it : null,
  root : null,
  src : null,
  dst :  null,

  trackingVisits : 1,
  iteratorExtension : null,
  iterationExtension : null,
  iterationPreserve : null,
  recursive : Infinity,

  onUp : null,
  onDown : null,

}

//

/**
 * @summary Replicates a complex data structure using iterator.
 * @param {Object} o Options map
 * @param {Object} o.it Iterator object
 * @param {Object} o.root
 * @param {Object} o.src Source data structure
 * @param {Object} o.dst Target data structure
 * @param {Boolean} o.trackingVisits=1
 * @param {} o.iteratorExtension=null
 * @param {} o.iterationExtension=null
 * @param {Boolean} o.iterationPreserve=null
 * @param {Number} o.recursive=Infinity
 *
 * @returns {Object} Returns `dst` structure.
 * @function replicateIt
 * @memberof module:Tools/base/Replicator.Tools( module::Replicator )
 */


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

/**
 * @summary Replicates a complex data structure.
 * @param {} src Source data scructure
 * @param {} dst Target data scructure
 *
 * @returns {} Returns `dst` structure.
 * @function replicate
 * @memberof module:Tools/base/Replicator.Tools( module::Replicator )
 */

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

if( typeof module !== 'undefined' && module !== null )
module[ 'exports' ] = Self;

})();
