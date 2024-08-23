import { Controller } from "https://unpkg.com/@hotwired/stimulus/dist/stimulus.js";

export class CheckboxOptionController extends Controller {
    connect() {}
  
    static targets = ["content"]

    renderContentById(event) {
        const target = event.currentTarget
        const value = target.value
        const params = JSON.parse(target.dataset.ajaxParams)
        
        if (value) {
            params['value'] = value
        }
        
        this._fetchContent(target.dataset.ajaxUrl, params, 'PUT')
    }
    
    _fetchContent(ajaxUrl, ajaxParams, type) {
        const csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute('content');
        
        $.ajax({
            url: ajaxUrl,
            type: type,
            dataType: 'json',
            data: ajaxParams,
            headers: {
                'X-CSRF-Token': csrfToken
            },
            success: (data) => {
                this.targets.find("content-" + data.container).innerHTML = data.content
            }
        }) 
    }
}
