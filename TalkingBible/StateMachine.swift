//
// Credit to jemmons 
// Blog entry: <http://www.figure.ink/blog/2015/1/31/swift-state-machines-part-1>
// Gist: <https://gist.github.com/jemmons/c9434cc09831a276003e>
//

import Foundation

class StateMachine<P:StateMachineDelegateProtocol>{
    private unowned let delegate:P
    private var _state:P.StateType{
        didSet{
            delegate.didTransitionFrom(oldValue, to:_state)
        }
    }
    var state:P.StateType{
        get{ return _state }
        set{
            if delegate.shouldTransitionFrom(_state, to:newValue){
                _state = newValue
            }
        }
    }
    init(initialState:P.StateType, delegate:P){
        _state = initialState
        self.delegate = delegate
    }
}



protocol StateMachineDelegateProtocol: class{
    typealias StateType
    func shouldTransitionFrom(from:StateType, to:StateType)->Bool
    func didTransitionFrom(from:StateType, to:StateType)
}