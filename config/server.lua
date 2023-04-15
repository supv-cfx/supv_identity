return {
    command = {
        name = 'identity', -- command not implemented for now
        authorized = {'admin'} -- used to secure event to set identity too (so if player is alreadyRegistered and he trigger event with executor lua and he havn't this group he is kick)
    }
}