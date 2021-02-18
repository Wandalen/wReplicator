( function _Replicator_s_()
{

'use strict';

/**
 * Collection of cross-platform routines to replicate a complex data structure. It traverse input data structure deeply producing a copy of it.Collection of cross-platform routines to replicate a complex data structure. It traverses input data structure deeply producing a copy of it.
  @module Tools/base/Replicator
  @extends Tools
*/

/**
 * Collection of cross-platform routines to replicate a complex data structure.
 */

if( typeof module !== 'undefined' )
{

  let _ = require( '../../../wtools/Tools.s' );

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

  if( !it.iterable )
  {
    it.dstWriteDown = function dstWriteDown( eit )
    {
      _.assert( 0, 'Cant write into terminal' );
    }
  }
  else if( it.iterable === _.looker.containerNameToIdMap.countable )
  {
    it.dstWriteDown = function dstWriteDown( eit )
    {
      if( eit.dst !== undefined )
      this.dst.push( eit.dst );
    }
  }
  else if( it.iterable === _.looker.containerNameToIdMap.auxiliary )
  {
    it.dstWriteDown = function dstWriteDown( eit )
    {
      if( eit.dst === undefined )
      delete this.dst[ eit.key ];
      else
      this.dst[ eit.key ] = eit.dst;
    }
  }
  else if( it.iterable === _.looker.containerNameToIdMap.hashMap )
  {
    it.dstWriteDown = function dstWriteDown( eit )
    {
      _.assert( 0, 'not tested' ); /* qqq : test */
      if( eit.dst === undefined )
      this.dst.delete( eit.key );
      else
      this.dst.set( eit.key, eit.dst );
    }
  }
  else if( it.iterable === _.looker.containerNameToIdMap.set )
  {
    it.dstWriteDown = function dstWriteDown( eit )
    {
      _.assert( 0, 'not tested' ); /* qqq : test */
      if( eit.dst === undefined )
      this.dst.delete( eit.dst );
      else
      this.dst.set( eit.dst );
    }
  }

}

//

function dstMake()
{
  let it = this;

  _.assert( it.dst === null );
  _.assert( it.iterable !== null && it.iterable !== undefined );
  _.assert( it.dstMaking );
  _.assert( arguments.length === 0 );

  if( !it.iterable )
  {
    it.dst = it.src;
  }
  else if( it.iterable === _.looker.containerNameToIdMap.countable )
  {
    it.dst = [];
  }
  else if( it.iterable === _.looker.containerNameToIdMap.auxiliary )
  {
    it.dst = Object.create( null );
  }
  else if( it.iterable === _.looker.containerNameToIdMap.hashMap )
  {
    it.dst = new HashMap;
  }
  else if( it.iterable === _.looker.containerNameToIdMap.set )
  {
    it.dst = new Set;
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

//

function visitUpEnd()
{
  let it = this;

  if( it.dstMaking )
  it.dstMake();

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

function replicate_head( routine, args )
{

  let o = args[ 0 ];
  if( args.length === 2 )
  {
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
    _.assert( Self.iterationIs( o.it ), () => 'Expects iteration of ' + Self.constructor.name + ' but got ' + _.toStrShort( o.it ) );
    _.assert( 0, 'not tested' ); /* xxx */
    o.src = o.it.src;
    o.prevReplicateIteration = o.it;
    // o.prevReplicateOptions = o.it.iterator;
    // o.prevReplicateOptions = o.it.replicateOptions;
  }

  let o2 = optionsFor( o );
  let it = _.look.head( _.replicate, [ o2 ] );

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

/* xxx qqq : implement please replication with buffer sepration
*/

// function cloneDataSeparatingBuffers( o )
// {
//   var result = Object.create( null );
//   var buffers = [];
//   var descriptorsArray = [];
//   var descriptorsMap = Object.create( null );
//   var size = 0;
//   var offset = 0;
//
//   _.routineOptions( cloneDataSeparatingBuffers, o );
//   _.assert( arguments.length === 1, 'Expects single argument' );
//
//   /* onBuffer */
//
//   o.onBuffer = function onBuffer( srcBuffer, it )
//   {
//
//     _.assert( arguments.length === 2, 'Expects exactly two arguments' );
//     _.assert( _.bufferTypedIs( srcBuffer ), 'not tested' );
//
//     var index = buffers.length;
//     var id = _.strJoin([ '--buffer-->', index, '<--buffer--' ]);
//     var bufferSize = srcBuffer ? srcBuffer.length*srcBuffer.BYTES_PER_ELEMENT : 0;
//     size += bufferSize;
//
//     let bufferConstructorName;
//     if( srcBuffer ) /* yyy */
//     {
//       let longDescriptor = _.LongTypeToDescriptorsHash.get( srcBuffer.constructor );
//
//       if( longDescriptor )
//       bufferConstructorName = longDescriptor.name;
//       else
//       bufferConstructorName = srcBuffer.constructor.name;
//
//     }
//     else
//     {
//       bufferConstructorName = 'null';
//     }
//
//     var descriptor =
//     {
//       'bufferConstructorName' : bufferConstructorName,
//       'sizeOfScalar' : srcBuffer ? srcBuffer.BYTES_PER_ELEMENT : 0,
//       'offset' : -1,
//       'size' : bufferSize,
//       'index' : index,
//     }
//
//     buffers.push( srcBuffer );
//     descriptorsArray.push( descriptor );
//     descriptorsMap[ id ] = descriptor;
//
//     it.dst = id;
//
//   }
//
//   /* clone data */
//
//   result.data = _._clone( o );
//   result.descriptorsMap = descriptorsMap;
//
//   /* sort by atom size */
//
//   descriptorsArray.sort( function( a, b )
//   {
//     return b[ 'sizeOfScalar' ] - a[ 'sizeOfScalar' ];
//   });
//
//   /* alloc */
//
//   result.buffer = new BufferRaw( size );
//   var dstBuffer = _.bufferBytesGet( result.buffer );
//
//   /* copy buffers */
//
//   for( var b = 0 ; b < descriptorsArray.length ; b++ )
//   {
//
//     var descriptor = descriptorsArray[ b ];
//     var buffer = buffers[ descriptor.index ];
//     var bytes = buffer ? _.bufferBytesGet( buffer ) : new U8x();
//     var bufferSize = descriptor[ 'size' ];
//
//     descriptor[ 'offset' ] = offset;
//
//     _.bufferMove( dstBuffer.subarray( offset, offset+bufferSize ), bytes );
//
//     offset += bufferSize;
//
//   }
//
//   return result;
// }
//
// cloneDataSeparatingBuffers.defaults =
// {
//   copyingBuffers : 1,
// }
//
// cloneDataSeparatingBuffers.defaults.__proto__ = cloneData.defaults;

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
 * @param {*} o.iteratorExtension=null
 * @param {*} o.iterationExtension=null
 * @param {Boolean} o.iterationPreserve=null
 * @param {Number} o.recursive=Infinity
 *
 * @returns {Object} Returns `dst` structure.
 * @function replicateIt
 * @namespace Tools
 * @module Tools/base/Replicator
 */


let replicateIt = _.routineUnite( replicate_head, replicateIt_body );

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
 * @param {*} src Source data scructure
 * @param {*} dst Target data scructure
 *
 * @returns {} Returns `dst` structure.
 * @function replicate
 * @namespace Tools
 * @module Tools/base/Replicator
 */

let replicate = _.routineUnite( replicate_head, replicate_body );

// --
// extend looker
// --

let Replicator = Object.create( Parent );
Replicator.constructor = function Replicator(){};
Replicator.Looker = Replicator;
Replicator.dstWriteDownEval = dstWriteDownEval;
Replicator.dstMake = dstMake;
Replicator.srcChanged = srcChanged;
Replicator.visitUpEnd = visitUpEnd;
Replicator.visitDownEnd = visitDownEnd;

let Iteration = Replicator.Iteration = _.mapExtend( null, Replicator.Iteration );
Iteration.dst = null;
Iteration.dstMaking = true;
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

if( typeof module !== 'undefined' )
module[ 'exports' ] = _;

})();
