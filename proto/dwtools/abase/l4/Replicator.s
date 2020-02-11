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

}

let _global = _global_;
let _ = _global_.wTools
let Parent = _.Looker;

let _ArraySlice = Array.prototype.slice;
let _FunctionBind = Function.prototype.bind;
let _ObjectToString = Object.prototype.toString;
let _ObjectHasOwnProperty = Object.hasOwnProperty;

_.assert( !!_realGlobal_ );

// --
// routines
// --

function dstWriteDownEval()
{
  let it = this;
  it.dstWriteDown = null;

  _.assert( it.iterable !== null && it.iterable !== undefined );
  _.assert( it.dstWriteDown === null );
  _.assert( _.routineIs( it.dstSet ) );

  if( !it.iterable )
  {
    it.dstWriteDown = function dstWriteDown( eit )
    {
      _.assert( 0, 'Cant write into terminal' );
    }
  }
  else if( it.iterable === 'long-like' )
  {
    it.dstWriteDown = function dstWriteDown( eit )
    {
      if( eit.dst !== undefined )
      this.dst.push( eit.dst );
    }
  }
  else if( it.iterable === 'map-like' )
  {
    it.dstWriteDown = function dstWriteDown( eit )
    {
      if( eit.dst === undefined )
      delete this.dst[ eit.key ];
      else
      this.dst[ eit.key ] = eit.dst;
    }
  }

}

//

function dstSet()
{
  let it = this;

  _.assert( it.dst === null );
  _.assert( it.iterable !== null && it.iterable !== undefined );
  _.assert( it.dstSetting );
  _.assert( arguments.length === 0 );

  if( !it.iterable )
  {
    it.dst = it.src;
  }
  else if( it.iterable === 'long-like' )
  {
    it.dst = [];
  }
  else if( it.iterable === 'map-like' )
  {
    it.dst = Object.create( null );
  }

}

//

function srcChanged()
{
  let it = this;

  _.assert( arguments.length === 0, 'Expects no arguments' );

  let result = Parent.srcChanged.call( it );

  it.dstWriteDownEval();

  return result;
}

// //
//
// function visitUp()
// {
//   let it = this;
//
//   it.visitUpBegin();
//
//   _.assert( it.visiting );
//   _.assert( it.iterable !== null && it.iterable !== undefined );
//   _.assert( _.routineIs( it.dstSet ) );
//
//   _.assert( _.routineIs( it.onUp ) );
//   let r = it.onUp.call( it, it.src, it.key, it );
//   _.assert( r === undefined );
//
//   /* */
//
//   // it.dstWriteDownEval();
//
//   if( it.dstSetting )
//   it.dstSet();
//
//   /* */
//
//   it.visitUpEnd()
//
// }

// //
//
// function visitDown()
// {
//   let it = this;
//
//   it.visitDownBegin();
//
//   if( it.visiting )
//   if( it.onDown )
//   {
//     let r = it.onDown.call( it, it.src, it.key, it );
//     _.assert( r === undefined );
//   }
//
//   /* */
//
//   _.assert( it.iterable !== null && it.iterable !== undefined );
//
//   if( it.down && it.dstWritingDown )
//   {
//     _.assert( _.routineIs( it.down.dstWriteDown ) );
//     it.down.dstWriteDown( it );
//   }
//
//   /* */
//
//   it.visitDownEnd();
//
//   return it;
// }

//

function visitUpEnd()
{
  let it = this;

  // it.dstWriteDownEval();

  if( it.dstSetting )
  it.dstSet();

  return Parent.visitDownEnd.call( it );
}

//

function visitDownEnd()
{
  let it = this;

  _.assert( it.iterable !== null && it.iterable !== undefined );

  if( it.down && it.dstWritingDown )
  {
    _.assert( _.routineIs( it.down.dstWriteDown ) );
    it.down.dstWriteDown( it );
  }

  return Parent.visitDownEnd.call( it );
}

//

function replicate_pre( routine, args )
{

  let o = args[ 0 ];
  if( args.length === 2 )
  {
    // if( _.lookIterationIs( args[ 0 ] ) )
    if( Self.iterationIs( args[ 0 ] ) )
    o = { it : args[ 0 ], dst : args[ 1 ] }
    else
    o = { src : args[ 0 ], dst : args[ 1 ] }
  }

  _.routineOptionsPreservingUndefines( routine, o );
  _.assert( arguments.length === 2 );
  _.assert( args.length === 1 || args.length === 2 );
  _.assert( o.onUp === null || _.routineIs( o.onUp ) );
  _.assert( o.onDown === null || _.routineIs( o.onDown ) );

  o.prevReplicateIteration = null;
  if( o.root === null )
  o.root = o.src;

  if( o.it )
  {
    _.assert( o.src === null );
    // _.assert( _.lookIterationIs( o.it ) );
    _.assert( Self.iterationIs( o.it ), () => 'Expects iteration of ' + Self.constructor.name + ' but got ' + _.toStrShort( o.it ) );
    _.assert( 0, 'not tested' );
    o.src = o.it.src;
    debugger; xxx
    o.prevReplicateIteration = o.it;
    // o.prevReplicateOptions = o.it.iterator;
    // o.prevReplicateOptions = o.it.replicateOptions;
  }

  let o2 = optionsFor( o );
  let it = _.look.pre( _.replicate, [ o2 ] );

  _.assert( o.it === it || o.it === null );

  return it;

  /* */

  function optionsFor( o )
  {

    let o2 = o;

    if( o2.Looker === null )
    o2.Looker = Self;

    _.assert( o2.replicateOptions === undefined );
    _.assert( arguments.length === 1 );

    return o2;
  }

}

//

function replicateIt_body( it )
{
  _.assert( arguments.length === 1, 'Expects single argument' );
  _.assert( _.lookerIs( it.Looker ) );
  _.assert( it.looker === undefined );
  _.look.body( it );
  return it;
}

var defaults = replicateIt_body.defaults = Object.create( _.look.defaults )

defaults.Looker = null;
defaults.it = null;
defaults.root = null;
defaults.src = null;
defaults.dst =  null;

defaults.prevReplicateIteration = null;

//

/**
 * @summary Replicates a complex data structure using iterator.
 * @param {Object} o Options map
 * @param {Object} o.it Iterator object
 * @param {Object} o.root
 * @param {Object} o.src Source data structure
 * @param {Object} o.dst Target data structure
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

_.routineExtend( replicate_body, replicateIt.body );

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
// extend looker
// --

let Replicator = Object.create( Parent );
Replicator.constructor = function Replicator(){};
Replicator.Looker = Replicator;
Replicator.dstWriteDownEval = dstWriteDownEval;
Replicator.dstSet = dstSet;
Replicator.srcChanged = srcChanged;
// Replicator.visitUp = visitUp;
// Replicator.visitDown = visitDown;
Replicator.visitUpEnd = visitUpEnd;
Replicator.visitDownEnd = visitDownEnd;

let Iteration = Replicator.Iteration = _.mapExtend( null, Replicator.Iteration );
Iteration.dst = null;
Iteration.dstSetting = true;
Iteration.dstWriteDown = null;
Iteration.dstWritingDown = true;

// --
// declare
// --

let Supplement =
{

  Replicator,

  replicateIt,
  replicate,

}

let Self = Replicator;
_.mapSupplement( _, Supplement );

// --
// export
// --

if( typeof module !== 'undefined' && module !== null )
module[ 'exports' ] = _;

})();
