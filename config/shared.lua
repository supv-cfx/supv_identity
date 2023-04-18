return {
    format_date = "DD/MM/YYYY", -- (DD/MM/YYYY or MM/DD/YYYY)

    height = {
        min = 120,
        max = 220
    },

    dob = {
        min = 1920,
        max = 2005
    },

    appearance = GetResourceState('illenium-appearance') ~= 'missing' and 'illenium-appearance' -- be logic pls...
}