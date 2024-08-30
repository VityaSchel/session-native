import Foundation

// muscular itshnik sidit and progaet na macbook (literlally me)
let imageMock1 = Data(base64Encoded: "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")!

// alex or something idk i'm not a pedo
let imageMock2 = Data(base64Encoded: "/9j/4AAQSkZJRgABAQAAAQABAAD/2wBDAFA3PEY8MlBGQUZaVVBfeMiCeG5uePWvuZHI////////////////////////////////////////////////////2wBDAVVaWnhpeOuCguv/////////////////////////////////////////////////////////////////////////wAARCADIAMgDASIAAhEBAxEB/8QAHwAAAQUBAQEBAQEAAAAAAAAAAAECAwQFBgcICQoL/8QAtRAAAgEDAwIEAwUFBAQAAAF9AQIDAAQRBRIhMUEGE1FhByJxFDKBkaEII0KxwRVS0fAkM2JyggkKFhcYGRolJicoKSo0NTY3ODk6Q0RFRkdISUpTVFVWV1hZWmNkZWZnaGlqc3R1dnd4eXqDhIWGh4iJipKTlJWWl5iZmqKjpKWmp6ipqrKztLW2t7i5usLDxMXGx8jJytLT1NXW19jZ2uHi4+Tl5ufo6erx8vP09fb3+Pn6/8QAHwEAAwEBAQEBAQEBAQAAAAAAAAECAwQFBgcICQoL/8QAtREAAgECBAQDBAcFBAQAAQJ3AAECAxEEBSExBhJBUQdhcRMiMoEIFEKRobHBCSMzUvAVYnLRChYkNOEl8RcYGRomJygpKjU2Nzg5OkNERUZHSElKU1RVVldYWVpjZGVmZ2hpanN0dXZ3eHl6goOEhYaHiImKkpOUlZaXmJmaoqOkpaanqKmqsrO0tba3uLm6wsPExcbHyMnK0tPU1dbX2Nna4uPk5ebn6Onq8vP09fb3+Pn6/9oADAMBAAIRAxEAPwC1RS1TupnD7FOKALdFV44mVd5kYnHSq8UxVzvZiKANCiqNu7NNyxI570ROxucFjjPTNAF6iqKu32rG44z0zU94xWMbSR9KAJ6KoAyCHzBI3XpTnmZ7cNkg57UAXaKzhIwQEStu9KlleQW6liQ2aALlFUYG3MN0j5z07U2WR1mOGPB6ZoA0KKoNMXmUhjj0zSz5+0DrQBeoqvPGCA7u20dhUMKuZt0eQme5oAvUVRbP2vv1qaeNQd8jsR6CgCxRVO3WTzNy5Ce5pIs/az1xQBdoqrOiK26RmbPQCktVkDZ5Ce9AFuilooAKgntxLyDhqk81P76/nSiRD0YfnQBDHFKvDOCuKbFbNG5JIINWNy+oo8xP7w/OgCvFbMku4sKEtmWbeWGKsb1/vD86N6/3h+dAFY2r+YXVwOae8EkkW1nBOetSmRB1YfnR50f99fzoArC0k27TINvpUj22YgiHGO5qXzo/76/nR50f99fzoArmzOwAEBh3p7wPJEEZhkd6l86P++v50edH/fX86AII4JYyAJBt9MUv2ZvO3kjHpU3nR/31/Ojzo/76/nQBX+yESbgwxnOKkeKUyArJgelSedH/AH1/Ojzo/wC+v50AJIrsmFbafWiJXRcO240vnR/31/OjzU/vr+dAEfly+bu8z5fSnzI7rhG2ml8xP7w/Ol8xP7w/OgBI1ZUwzZPrUaRyiTc0mV9Kk8xP7w/OjzE/vD86AGTJI+Nj7akjDKgDHJ9aTzU/vr+dHmx/31/OgB9FM86P++v50UAZYJFPD1HRQBYWX1qT5GHFVASKXfSsMskYpN1QGRj3pyxu3NKwD3YY9ah2n0NThdvXrTgc0XsBUoqzIgIquRg00xCUUUUwCiiigAooqRF5yaAFSItyTigxsOnNSjinquam47FUOVPNP8wGpjEjHkU0269qLoBm9fWguKVoQOtMeMKuc0wGM2TTaKKYgooooAKKKKACiiigCWIA9etTIccVWjOGqcVLGiRxnmmCpFORimsMGkMMZFQSpg5qwuKa/INCEVKKVhg0lWIKKKKAHIuTU4FJGoC0/wClS2MFGTUg4oVcCikMWj8aSmucCkAjHcagmbtTydoyagJyc1SQmJRRRVCCiiigAooooAKKKKACp42ytQU5W2mkwLSnFObkVAJBThLxU2GPFB5qMMKXfQMilGDmo6mYF+1N8o+tUiSOnxjLU7yj60KhU560wJR0pycmmbvUGm7sHIapGWqTioBMfTP0p3mj+6aVhkpwBmoicnNBYt14FQyP2FCQhJWycVHRRViCiiigAooooAKKKKACiiigAoopVGTQAqgk8VKF9aFGKfUsYgUUu0UUtIYBRQaWjFACCl+lGKQUAGD6UhUHqKeDSGgCIxDGVJFM3MDg4qxTHUU7iInZuhqOpSuVxUVMQUUUUwCiiigAooooAKKKKACiiigAqZEO3OKfAqqm4jJqaOVWPQfhQBVbcP4fzpu89qvyKKqyKgJzwaQxI33cHrUgqGIYOanTBPNJgNYnoo5qNi4/vVZEiA4x+tP2qy5FOwFHzD6frSiQe4qWWNDyeKruADwcigROGxz1HqKkzkZFVUYr9PSpoWyppNDHUHmlxiikMjqKQc1OV71FJ0poRFRRRVCCiiigAooooAKKKKACiiigB6SFOOo9KlSVV5CAGq9SIMigCVpmaosZOWOaeV9KbhvSkMUUbmRsrzRhvQ0u1j2NABuRjuYMD7GpftA24UGkCDHNLtA7UrhYicu/RTimiFz2xVgGl3UXCxCsAHU5qQKFGBTjTTSuMCaaTRSGgALcVE5pznjiojVJCEooopiCiiigAooooAKKKKACiiigAqSM1HSigCwDS1CVcLnHFCuP4i34VNh3LApc1AXXHDNn6Uode7n8qLBcmpartIARtYkfSnecvq9FguPbikBqJpctlRx70hmY9MD6CiwXJy6juKYZl9zUHWgDJxTsFyxGd+TkAD1qNyeuflqZ1jSIKACx71HtCpg80ARu+7jtTKU9aSmIKKKKACiiigAooooAKKKKACiiigByru+lSbdvSiL0NPYfLSGOVg8ZQ8GqzKV6gin5z16+tSJKwGDhl96AK9GKn2wnqGWkMcWRhzimIhxRU/kxH/lr+lIixAkPk/SgCEU9Iy5+UZqcmLBCxmo03ITt4+poAX7MRyxGO4HWpN6hNkS8dyab1+8xNDMAKVxjMBaa2W6GkZix4p0aEcmgCIqR1FJVkjPWmqozRcQxEBzuz+FPESEDkg96eaAKLjI/KXPU4oMajs31qXFBFFwsV8KBycn2oqVlBHNFFwsV6KKKYgqSNM8mmAZNTrSYC/dyCOD3pmXUf3hUtI20DOKLjIME9qcOKctOwDSAaGpd1LsFGwetAxNw9KXdShBS7RQIYXz2pPmPQVJgUoFAyMIe5pfLHpUmKaaVwEAHanAU2lHFAhcUhXByKXNGaBh1oApj7g4296aZcHDAg0xE1MMi5xmoXJPIPFMBwaLBckZ+fUUVGOtFUISiiigBydalFRIcGphSY0KDzSSdBS5pr9qkAHSnKM0g54qQcUwF2ijb70tFIYm00YNNeUJ15NIk+48jFAh2DSgGnilpDIzSYqcAEU3AoAixRTyKQimAyilIpDxQAjDIqF2J68mpqjkTPI600IajetSAL6VEENOBxwabAlAHoKKQGikBWoooqhBUwyo5oooAXNIx4ooqRjkp9FFADhS5oopDGuiuOaasKg560UUXES0tFFIYUtFFABTWoooAZmiiimAYpDRRQA09Khbg5oopoQ5Wooopgf/Z")!

// lgbt pride let's go
let imageMock3 = Data(base64Encoded: "/9j/4AAQSkZJRgABAQAAAQABAAD/2wBDAFA3PEY8MlBGQUZaVVBfeMiCeG5uePWvuZHI////////////////////////////////////////////////////2wBDAVVaWnhpeOuCguv/////////////////////////////////////////////////////////////////////////wAARCADIAMgDASIAAhEBAxEB/8QAHwAAAQUBAQEBAQEAAAAAAAAAAAECAwQFBgcICQoL/8QAtRAAAgEDAwIEAwUFBAQAAAF9AQIDAAQRBRIhMUEGE1FhByJxFDKBkaEII0KxwRVS0fAkM2JyggkKFhcYGRolJicoKSo0NTY3ODk6Q0RFRkdISUpTVFVWV1hZWmNkZWZnaGlqc3R1dnd4eXqDhIWGh4iJipKTlJWWl5iZmqKjpKWmp6ipqrKztLW2t7i5usLDxMXGx8jJytLT1NXW19jZ2uHi4+Tl5ufo6erx8vP09fb3+Pn6/8QAHwEAAwEBAQEBAQEBAQAAAAAAAAECAwQFBgcICQoL/8QAtREAAgECBAQDBAcFBAQAAQJ3AAECAxEEBSExBhJBUQdhcRMiMoEIFEKRobHBCSMzUvAVYnLRChYkNOEl8RcYGRomJygpKjU2Nzg5OkNERUZHSElKU1RVVldYWVpjZGVmZ2hpanN0dXZ3eHl6goOEhYaHiImKkpOUlZaXmJmaoqOkpaanqKmqsrO0tba3uLm6wsPExcbHyMnK0tPU1dbX2Nna4uPk5ebn6Onq8vP09fb3+Pn6/9oADAMBAAIRAxEAPwAoooqDoCkpaSgYUlFFAwooooAKSlpGBGKADOOTTDISeKR2zxTRTIbHlm28mmZNPCl8ClZdvagLEeaXdxSGkoJuGaKBUgAoBK4yl+tPpMUFWGMcim09wNtMpoiW4UUUUEi5I6UUlFAXLdFFIxwM1JsIzAcd6aGyeKYDnJPepIxQCYuMUUp60lBQUUlFAD0UEEnoKjZuC35U5WJhOOpNMk4UCgjzIhUkSbjntTQM8VZjGFpiSJEUKKRgD1ozSGgCtIm1uOlR1PKMrUFAmgqQGmDrSigaH0UmaM0irjXPFMqQ801lx0poiS6jaKKKZAUUlFAF2oZWycVKx2qTVcDJrOJTY7HygVKowtM71I3AAobAbSUUUDuF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")!