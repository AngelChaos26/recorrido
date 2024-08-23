import { Controller } from "https://unpkg.com/@hotwired/stimulus/dist/stimulus.js";

export class SelectOptionController extends Controller {
    connect() {}
  
    static targets = ["content"]

    renderContentById(event) {
        const target = event.currentTarget
        const option = target.selectedOptions[0]
        
        if (option) {
            this._fetchContent(option.dataset.ajaxUrl, JSON.parse(option.dataset.ajaxParams))
        }
    }
    
    _fetchContent(ajaxUrl, ajaxParams) {
        $.ajax({
            url: ajaxUrl,
            type: 'GET',
            dataType: 'json',
            data: ajaxParams,
            success: (data) => {
                this.contentTarget.innerHTML = data.content
            }
        }) 
    }
}
