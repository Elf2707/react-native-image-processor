using ReactNative.Bridge;
using System;
using System.Collections.Generic;
using Windows.ApplicationModel.Core;
using Windows.UI.Core;

namespace Image.Processor.RNImageProcessor
{
    /// <summary>
    /// A module that allows JS to share data.
    /// </summary>
    class RNImageProcessorModule : NativeModuleBase
    {
        /// <summary>
        /// Instantiates the <see cref="RNImageProcessorModule"/>.
        /// </summary>
        internal RNImageProcessorModule()
        {

        }

        /// <summary>
        /// The name of the native module.
        /// </summary>
        public override string Name
        {
            get
            {
                return "RNImageProcessor";
            }
        }
    }
}
