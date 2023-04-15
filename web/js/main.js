window.addEventListener('message', (event) => {
    if (event.data.action === 'convertUnix') {
        const unixTime = moment.duration(event.data.unix, 'milliseconds').as('seconds');
        const date = moment.unix(unixTime);
        const formated = date.format(event.data.format_date)
        
        fetch(`https://${GetParentResourceName()}/returnDate`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json; charset=UTF-8',
            },
            body: JSON.stringify(formated)
        });
    }
});