#BEGIN_HEADER
#END_HEADER


class Onerepotest:
    '''
    Module Name:
    Onerepotest

    Module Description:
    
    '''

    ######## WARNING FOR GEVENT USERS #######
    # Since asynchronous IO can lead to methods - even the same method -
    # interrupting each other, you must be *very* careful when using global
    # state. A method could easily clobber the state set by another while
    # the latter method is running.
    #########################################
    #BEGIN_CLASS_HEADER
    #END_CLASS_HEADER

    # config contains contents of config file in a hash or None if it couldn't
    # be found
    def __init__(self, config):
        #BEGIN_CONSTRUCTOR
        #END_CONSTRUCTOR
        pass

    def send_data(self, ctx, params):
        # ctx is the context object
        # return variables are: returnVal
        #BEGIN send_data
        user = ctx['user_id']
        returnVal = {'params': params, 'user': user}
        #END send_data

        # At some point might do deeper type checking...
        if not isinstance(returnVal, object):
            raise ValueError('Method compare_genome_features return value ' +
                             'returnVal is not type object as required.')
        # return the results
        return [returnVal]
