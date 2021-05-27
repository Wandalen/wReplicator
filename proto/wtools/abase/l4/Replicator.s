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

  const _ = require( '../../../node_modules/Tools' );

  _.include( 'wLooker' );

}

const _global = _global_;
const _ = _global_.wTools
const Parent = _.looker.Looker;
_.replicator = _.replicator || Object.create( _.looker );

_.assert( !!_realGlobal_ );

/* qqq : write nice example for readme */

// --
// relations
// --

var Prime = Object.create( null );
Prime.src = undefined;
Prime.dst = undefined;

// --
// implementation
// --

function head( routine, args )
{
  let o = routine.defaults.Seeker.optionsFromArguments( args );
  o.Seeker = o.Seeker || routine.defaults;
  _.map.assertHasOnly( o, o.Seeker );
  let it = o.Seeker.optionsToIteration( null, o );
  return it;
}

//

function optionsFromArguments( args )
{
  let o = args[ 0 ];

  if( args.length === 2 )
  {
    if( _.replicator.iterationIs( args[ 0 ] ) )
    o = { it : args[ 0 ], dst : args[ 1 ] }
    else
    o = { src : args[ 0 ], dst : args[ 1 ] }
  }

  _.assert( args.length === 1 || args.length === 2 );
  _.assert( arguments.length === 1 );
  _.assert( _.mapIs( o ) );

  return o;
}

//

function optionsToIteration( iterator, o )
{
  // debugger;
  let it = Parent.optionsToIteration.call( this, iterator, o );
  _.assert( arguments.length === 2 );
  _.assert( _.props.has( it, 'dst' ) );
  // _.assert( it.dst === undefined );
  _.assert( it.dst !== null );
  return it;
}

//

function iteratorInitEnd( iterator )
{
  let looker = this;

  _.assert( arguments.length === 1 );
  _.assert( iterator.iteratorProper( iterator ) );
  _.assert( iterator.onUp === null || _.routineIs( iterator.onUp ) );
  _.assert( iterator.onDown === null || _.routineIs( iterator.onDown ) );
  _.assert( iterator.it === undefined );
  _.assert( iterator.replicateOptions === undefined );

  return Parent.iteratorInitEnd.call( this, iterator );
}

//

function performBegin()
{
  let it = this;
  Parent.performBegin.apply( it, arguments );
  _.assert( it.iterationProper( it ) );
  _.assert( arguments.length === 0, 'Expects no arguments' );
  return it;
}

//

function performEnd()
{
  let it = this;
  it.iterator.originalResult = it.dst;
  it.iterator.result = it.iterator.originalResult;
  Parent.performEnd.apply( it, arguments );
  return it;
}

//

/* xxx : remove the routine? */
function dstWriteDownEval()
{
  let it = this;
  it.dstWriteDown = null;

  _.assert( it.iterable !== null && it.iterable !== undefined );
  _.assert( it.dstWriteDown === null );

  /* xxx : optimize */
  if( !it.iterable )
  {
    it.dstWriteDown = function dstWriteDown( eit )
    {
      _.assert( 0, 'Cant write into terminal' );
    }
  }
  else if( it.iterable === it.ContainerType.countable )
  {
    it.dstWriteDown = function dstWriteDown( eit )
    {
      if( eit.dst !== undefined )
      this.dst.push( eit.dst );
    }
  }
  else if( it.iterable === it.ContainerType.aux )
  {
    it.dstWriteDown = function dstWriteDown( eit )
    {
      if( eit.dst === undefined )
      delete this.dst[ eit.key ];
      else
      this.dst[ eit.key ] = eit.dst;
    }
  }
  else if( it.iterable === it.ContainerType.hashMap )
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
  else if( it.iterable === it.ContainerType.set )
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
  else _.assert( 0 );

}

//

function dstMake()
{
  let it = this;

  _.assert( it.iterable !== null && it.iterable !== undefined );
  _.assert( it.dstMaking );
  _.assert( arguments.length === 0 );

  _.assert( it.dst !== null );
  if( it.dst !== undefined )
  return;

  if( !it.iterable || it.iterable === it.ContainerType.custom )
  {
    it.dst = it.src;
  }
  else if( it.iterable === it.ContainerType.countable )
  {
    it.dst = [];
  }
  else if( it.iterable === it.ContainerType.aux )
  {
    it.dst = Object.create( null );
  }
  else if( it.iterable === it.ContainerType.hashMap )
  {
    it.dst = new HashMap;
  }
  else if( it.iterable === it.ContainerType.set )
  {
    it.dst = new Set;
  }
  else _.assert( 0 );

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

function exec_head( routine, args )
{
  _.assert( !!routine.defaults.Seeker );
  return routine.defaults.head( routine, args );
}

//

/* zzz qqq : implement please replication with buffer sepration
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
//   _.routine.options_( cloneDataSeparatingBuffers, o );
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
//     if( srcBuffer )
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

/**
 * @summary Replicates a complex data structure using iterator.
 * @param {Object} o Options map
 * @param {Object} o.it Iterator object
 * @param {Object} o.root
 * @param {Object} o.src Source data structure
 * @param {Object} o.dst Target data structure
 * @param {Number} o.recursive=Infinity
 *
 * @returns {Object} Returns `dst` structure.
 * @function replicateIt
 * @namespace Tools
 * @module Tools/base/Replicator
 */

function exec_body( it )
{
  // debugger;
  it.execIt.body.call( this, it );
  // _.assert( arguments.length === 1, 'Expects single argument' );
  // if( it.error && it.error !== true )
  // throw it.error;
  return it.result;
}

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

// --
// relations
// --

let LookerExtension =
{
  constructor : function Replicator(){},
  head,
  optionsFromArguments,
  optionsToIteration,
  iteratorInitEnd,
  performBegin,
  performEnd,
  dstWriteDownEval,
  dstMake,
  srcChanged,
  visitUpEnd,
  visitDownEnd,
}

let Iterator = Object.create( null );
Iterator.result = undefined;
Iterator.originalResult = undefined;

let Iteration = Object.create( null );
Iteration.dst = undefined;
Iteration.dstMaking = true;
Iteration.dstWriteDown = null;
Iteration.dstWritingDown = true;

let Replicator = _.looker.classDefine
({
  name : 'Replicator',
  parent : _.looker.Looker,
  prime : Prime,
  seeker : LookerExtension,
  iterator : Iterator,
  iteration : Iteration,
  exec : { head : exec_head, body : exec_body },
});

_.assert( !_.props.has( Replicator.Iteration, 'src' ) && Replicator.Iteration.src === undefined );
_.assert( _.props.has( Replicator.IterationPreserve, 'src' ) && Replicator.IterationPreserve.src === undefined );
_.assert( _.props.has( Replicator, 'src' ) && Replicator.src === undefined );
_.assert( _.props.has( Replicator.Iteration, 'dst' ) && Replicator.Iteration.dst === undefined );
_.assert( _.props.has( Replicator, 'dst' ) && Replicator.dst === undefined );
_.assert( _.props.has( Replicator.Iterator, 'result' ) && Replicator.Iterator.result === undefined );
_.assert( _.props.has( Replicator, 'result' ) && Replicator.result === undefined );

//

let ReplicatorExtension =
{

  name : 'replicator',
  Seeker : Replicator,
  Replicator,
  replicateIt : Replicator.execIt,
  replicate : Replicator.exec,

}

let ToolsExtension =
{

  replicate : Replicator.exec,

}

const Self = Replicator;
_.props.extend( _, ToolsExtension );
_.props.extend( _.replicator, ReplicatorExtension );

// --
// export
// --

if( typeof module !== 'undefined' )
module[ 'exports' ] = _;

})();
