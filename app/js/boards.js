/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 *
 * Copyright (c) 2021-present Kaleidos Ventures SL
 */

function initBoard() {
    var eventsCallback = function() {};
    var kanbanStatusObservers = {};

    return {
        events: function(cb) {
            eventsCallback = cb;
        },
        addCard: function(card, statusId, swimlaneId) {
            if (swimlaneId) {
                kanbanStatusObservers[swimlaneId][statusId].observe(card);
            } else {
                kanbanStatusObservers[statusId].observe(card);
            }
        },
        addSwimlane: function(column, statusId, swimlaneId) {
            var options = {
                root: column,
                rootMargin: '0px',
                threshold: 0
            }

            var callback = function(entries) {
                entries = entries.map((entry) => {
                    return {
                        id: Number(entry.target.dataset.id),
                        visible: entry.isIntersecting
                    };
                }).filter((entry) => {
                    return entry.visible
                });

                if (entries.length) {
                    eventsCallback('SHOW_CARD', entries);
                }
            };

            if (swimlaneId) {
                if (!kanbanStatusObservers[swimlaneId]) {
                    kanbanStatusObservers[swimlaneId] = {};
                }

                kanbanStatusObservers[swimlaneId][statusId] = new IntersectionObserver(callback, options);
            } else {
                if (!kanbanStatusObservers[statusId]) {
                    kanbanStatusObservers[statusId] = new IntersectionObserver(callback, options);
                }
            }
        },
    }
}
